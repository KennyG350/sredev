module ListingFavoriteButton.Update exposing (update, addEventListenerCmd)


import Maybe
import Json.Encode as JE
import Ports.Auth as Auth
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Config
import UserActivity exposing (UserActivity)
import ListingFavoriteButton.Types exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveBroadcast ("newSearchResultsRendered", _) ->
      (model, addEventListenerCmd model.containerSelector)

    OnClick (_, { data }, _) -> -- No need to constrain selector; only 1 click listener is registered
      let
        isFavorited = (Dom.dataAttribute data "favorited") == Just "true"
        listingIdMaybe = Dom.dataAttribute data "listingId"
      in
        case (listingIdMaybe, isFavorited) of
          (Just listingId, False) ->
            update (FavoriteListing listingId) model

          (Just listingId, True) ->
            update (UnfavoriteListing listingId) model

          _ ->
            model ! []

    ReceiveUserId userId ->
      { model | userId = userId } ! []

    _ ->
      msg
      |> msgToMaybeActivity
      |> Maybe.andThen (Just << activityToCmds model.userId)
      |> Maybe.withDefault Cmd.none
      |> \cmd ->
           (model, cmd)


buttonSelector : String -> String
buttonSelector listingId =
  Config.favoriteListingButtonSelectorPrefix ++ listingId


msgToMaybeActivity : Msg -> Maybe UserActivity
msgToMaybeActivity msg =
  case msg of
    FavoriteListing listingId ->
      Just (UserActivity.FavoriteListing listingId)

    UnfavoriteListing listingId ->
      Just (UserActivity.UnfavoriteListing listingId)

    _ ->
      Nothing


activityToCmds : Maybe UserId -> UserActivity -> Cmd Msg
activityToCmds userId activity =
  Cmd.batch
    [ pubSubCmd activity
    , userId
      |> Maybe.map (always (domCmd activity))
      |> Maybe.withDefault Cmd.none
    , userId
      |> Maybe.map (always Cmd.none)
      |> Maybe.withDefault (Auth.showAuth0Modal Nothing)
    ]


pubSubCmd : UserActivity -> Cmd Msg
pubSubCmd activity =
  case activity of
    UserActivity.FavoriteListing listingId ->
      PubSub.broadcast ("favoriteListing", JE.string listingId)

    UserActivity.UnfavoriteListing listingId ->
      PubSub.broadcast ("unfavoriteListing", JE.string listingId)

    _ ->
      Cmd.none


domCmd : UserActivity -> Cmd Msg
domCmd activity =
  case activity of
    UserActivity.FavoriteListing listingId ->
      Config.favoriteListingButtonFavoritedClasses
      |> List.map (\c -> Dom.addClass (buttonSelector listingId, c)) -- Add every possible favorited class
      |> List.append [Dom.setDataAttribute (buttonSelector listingId, "favorited", "true")] -- Set data attribute
      |> Cmd.batch

    UserActivity.UnfavoriteListing listingId ->
      Config.favoriteListingButtonFavoritedClasses
      |> List.map (\c -> Dom.removeClass (buttonSelector listingId, c)) -- Remove every possible favorited class
      |> List.append [Dom.setDataAttribute (buttonSelector listingId, "favorited", "false")] -- Set data attribute
      |> Cmd.batch

    _ ->
      Cmd.none


addEventListenerCmd : Selector -> Cmd Msg
addEventListenerCmd containerSelector =
  Dom.addEventListener
    ( containerSelector ++ " .elm-favorite-listing-button"
    , "click"
    , Just { stopPropagation = True, preventDefault = True }
    )
