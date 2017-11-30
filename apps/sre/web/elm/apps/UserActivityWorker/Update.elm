module UserActivityWorker.Update exposing (update, newRouteCmd)


import Json.Encode as JE
import Json.Decode as JD exposing (decodeValue, list, string)
import Ports.LocalStorage as LocalStorage
import Ports.Websocket as Websocket
import Ports.Dom as Dom
import Config
import UserActivity exposing (..)
import UserActivityWorker.Types exposing (..)


type alias ListingIdPayload =
  { listing_id : String
  }

type alias FailedToSaveViewedListingPayload =
  { url : String
  }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveUserId userId ->
      { model | userId = userId } ! []

    StorageGetItemResponse ("pendingFavorites", pendingFavoritesValue) ->
      pendingFavoritesValue
      |> decodeValue (list string)
      |> Result.map (\f -> update (ReceivePendingFavorites f) model)
      |> Result.withDefault
           (model ! [])

    StorageGetItemResponse ("pendingListingViews", pendingViewedListingsValue) ->
      pendingViewedListingsValue
      |> decodeValue (list string)
      |> Result.map (\urls -> update (ReceivePendingListingView urls) model)
      |> Result.withDefault
            (model ! [])

    ReceivePendingFavorites pendingFavorites ->
      case model.userId of
        Just _ ->
          model !
          [ pendingFavorites
            |> List.map (FavoriteListing >> (maybeWebsocketCmd model.userId))
            |> Cmd.batch
          , pendingFavorites
            |> List.map (\id -> Config.favoriteListingButtonSelectorPrefix ++ id)
            |> List.map ( -- Add every possible "favorited" class, so we can do 1 lazy operation
                 \selector -> List.map
                   (\c -> Dom.addClass (selector, c))
                   Config.favoriteListingButtonFavoritedClasses
               )
            |> List.concat
            |> Cmd.batch
          ]

        Nothing ->
          model ! []

    ReceivePendingListingView pendingViewListings ->
      case model.userId of
        Just _ ->
          model !
          [ pendingViewListings
            |> List.map (ViewedListing >> (maybeWebsocketCmd model.userId))
            |> Cmd.batch
          , pendingViewListings
            |> List.map (\url -> LocalStorage.storageRemoveFromSet ("pendingListingViews", JE.string url))
            |> Cmd.batch
          ]

        Nothing ->
          model ! []

    WebsocketReceive ("user", "favorite_listing_success", payload) ->
      case decodeListingIdPayload payload of
        Ok { listing_id } ->
          ( model
          , LocalStorage.storageRemoveFromSet ("pendingFavorites", JE.string listing_id)
          )

        Err error ->
          model ! []

    WebsocketReceive ("user", "failed_saving_viewed_listing", payload) ->
      case decodeActivityPayload payload of
        Ok { url } ->
          model !
          [ LocalStorage.storagePushToSet ("pendingListingViews", JE.string url)
          ]
        Err error ->
          model ! []


    UrlUpdate _ ->
      (model, newRouteCmd)

    _ ->
      msg
      |> msgToMaybeActivity
      |> Maybe.andThen (Just << activityToCmds model.userId)
      |> Maybe.withDefault Cmd.none
      |> \cmd ->
           (model, cmd)


newRouteCmd : Cmd Msg
newRouteCmd =
  Cmd.batch
    [ LocalStorage.storageGetItem ("pendingFavorites")
    , LocalStorage.storageGetItem ("pendingListingViews")
    ]


msgToMaybeActivity : Msg -> Maybe UserActivity
msgToMaybeActivity msg =
  case msg of
    ReceiveBroadcast ("favoriteListing", payload) ->
      case decodeValue string payload of
        Ok listingId ->
          Just (FavoriteListing listingId)

        Err _ ->
          Nothing

    ReceiveBroadcast ("unfavoriteListing", payload) ->
      case decodeValue string payload of
        Ok listingId ->
          Just (UnfavoriteListing listingId)

        Err _ ->
          Nothing

    ReceiveBroadcast ("viewedListing", payload) ->
      Nothing

    _ ->
      Nothing


activityToCmds : Maybe UserId -> UserActivity -> Cmd Msg
activityToCmds userId activity =
  Cmd.batch
    [ localStorageCmd activity
    , maybeWebsocketCmd userId activity
    ]


localStorageCmd : UserActivity -> Cmd Msg
localStorageCmd activity =
  case activity of
    FavoriteListing listingId ->
      LocalStorage.storagePushToSet ("pendingFavorites", JE.string listingId)

    UnfavoriteListing listingId ->
      LocalStorage.storageRemoveFromSet ("pendingFavorites", JE.string listingId)

    _ ->
      Cmd.none


maybeWebsocketCmd : Maybe UserId -> UserActivity -> Cmd Msg
maybeWebsocketCmd userId activity =
  case userId of
    Just _ ->
      websocketCmd activity

    Nothing ->
      Cmd.none


websocketCmd : UserActivity -> Cmd Msg
websocketCmd activity =
  case activity of
    FavoriteListing listingId ->
      Websocket.websocketSend
        ( "user"
        , "favorite_listing"
        , JE.object [( "listing_id", JE.string listingId )]
        )

    UnfavoriteListing listingId ->
      Websocket.websocketSend
        ( "user"
        , "unfavorite_listing"
        , JE.object [( "listing_id", JE.string listingId )]
        )

    ViewedListing url ->
      Websocket.websocketSend
        ( "user"
        , "viewed_listing"
        , JE.object [( "url", JE.string url )]
        )


decodeListingIdPayload : JE.Value -> Result String ListingIdPayload
decodeListingIdPayload =
  JD.decodeValue <|
    JD.map ListingIdPayload <|
      JD.field "listing_id" JD.string


decodeActivityPayload : JE.Value -> Result String FailedToSaveViewedListingPayload
decodeActivityPayload =
  JD.decodeValue <|
    JD.map FailedToSaveViewedListingPayload <|
      JD.field "url" JD.string
