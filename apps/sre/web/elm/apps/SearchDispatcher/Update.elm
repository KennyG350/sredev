module SearchDispatcher.Update exposing (update)


import Maybe
import Json.Encode as JE
import Json.Decode as JD
import Maybe.Extra as ME
import Ports.Analytics as Analytics
import Ports.PubSub as PubSub
import Ports.GoogleMaps as GoogleMaps
import RouteHelper
import Route exposing (Route(..))
import Config
import SearchParameters exposing (SearchParameters, updateSortOption)
import SearchDispatcher.Types exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveBroadcast ("searchFiltersChanged", filters) ->
      filters
      |> SearchParameters.fromJson
      |> \params ->
           { model | searchParameters = params } !
           [ cardsSearchCmd params
           , mapSearchCmd params
           , updateUrlCmd params model.route
           ]

    ReceiveBroadcast ("searchSortChanged", sortOption) ->
      case JD.decodeValue JD.string sortOption of
        Ok sortOption_ ->
          model.searchParameters
          |> updateSortOption sortOption_
          |> \params -> { params | page = 1 }
          |> \params ->
               { model | searchParameters = params } !
               [ cardsSearchCmd params
               , updateUrlCmd params model.route
               ]

        Err _ ->
          model ! []


    ReceiveBroadcast ("mapBoundsChanged", bounds) ->
      let
        latLngBounds =
          bounds
          |> JD.decodeValue JD.string
          |> Result.toMaybe
          |> Maybe.map GoogleMaps.latLngBoundsFromString
          |> ME.join

        params = model.searchParameters
        updatedParams = { params | bounds = latLngBounds, page = 1 }
      in
        ( { model | searchParameters = updatedParams }
        , case latLngBounds of
            Just _ ->
              Cmd.batch
                [ cardsSearchCmd updatedParams
                , mapSearchCmd updatedParams
                , updateUrlCmd updatedParams model.route
                ]

            Nothing ->
              Cmd.none
        )

    ReceiveBroadcast ("decrementedSearchPage", _) ->
      let
        { searchParameters } = model
        updatedParams =
          { searchParameters
          | page = max 1 <| searchParameters.page - 1
          }
      in
        { model | searchParameters = updatedParams } !
        [ cardsSearchCmd updatedParams
        , updateUrlCmd updatedParams model.route
        ]

    ReceiveBroadcast ("incrementedSearchPage", _) ->
      let
        { searchParameters } = model
        updatedParams =
          { searchParameters
          | page = searchParameters.page + 1
          }
      in
        { model | searchParameters = updatedParams } !
        [ cardsSearchCmd updatedParams
        , updateUrlCmd updatedParams model.route
        ]

    ReceiveBroadcast ("listingDetailsModalOpened", listingUrl) ->
      case JD.decodeValue JD.string listingUrl of
        Ok url ->
          if model.route == Just (Search (Just url)) then
            -- The user pressed forward/back browser button; we don't need to update the URL
            model ! []

          else
            ( model
            , updateUrlCmd
                model.searchParameters
                (Just (listingDetailsModalRoute url))
            )

        Err _ ->
          model ! []

    ReceiveBroadcast ("listingDetailsModalClosed", _) ->
      ( { model | route = Just (Search Nothing) }
      , updateUrlCmd model.searchParameters Nothing
      )

    ReceiveBroadcast ("groupMarkerClicked", payload) ->
      case decodeMarkerGroup payload of
        Ok ({ latLng } :: _) ->
          ( model
          , PubSub.broadcast
              ( "openMultiUnitModal"
              , JE.object
                  [ ("propertyLatLng", GoogleMaps.latLngToJson latLng)
                  , ( "currentSearchParameters"
                    , JE.string <| SearchParameters.toQueryParams model.searchParameters
                    )
                  ]
              )
          )

        _ ->
          model ! []

    UrlUpdate location ->
      let
        params = SearchParameters.fromQueryParams location.search
      in
        if params == model.searchParameters then
          model ! []

        else
          -- All `update` cases update the model, so when `else` is reached we can
          -- assume the user clicked the forward/back button in their browser
          { model
          | searchParameters = params
          , route = Route.fromLocation location
          } !
          [ cardsSearchCmd params
          , mapSearchCmd params
          , params.bounds
            |> Maybe.map fitMapToBoundsCmd
            |> Maybe.withDefault Cmd.none
          ]

    _ ->
      model ! []


cardsSearchCmd : SearchParameters -> Cmd Msg
cardsSearchCmd params =
  Cmd.batch
    [ PubSub.broadcast ("performNewCardsSearch", SearchParameters.toJson params)
    , params
      |> SearchParameters.toQueryParams
      |> \queryParams ->
           Analytics.gaPageView ("/properties" ++ queryParams, "Search")
    ]


mapSearchCmd : SearchParameters -> Cmd Msg
mapSearchCmd params =
  PubSub.broadcast ("performNewMapSearch", SearchParameters.toJson params)


updateUrlCmd : SearchParameters -> Maybe Route -> Cmd Msg
updateUrlCmd params route =
  RouteHelper.newUrl <|
    urlFromParamsAndModal params route


urlFromParamsAndModal : SearchParameters -> Maybe Route -> String
urlFromParamsAndModal params route =
  let
    modalParam =
      case route of
        Just (Search (Just listingUrlSlug)) ->
          "&" ++ Config.listingModalQueryParam ++ "=" ++ listingUrlSlug

        _ ->
          ""
  in
    "/properties"
    ++ (SearchParameters.toQueryParams params)
    ++ modalParam


fitMapToBoundsCmd : GoogleMaps.LatLngBounds -> Cmd Msg
fitMapToBoundsCmd bounds =
  PubSub.broadcast ("fitMapToNewBounds", GoogleMaps.latLngBoundsToJson bounds)


listingDetailsModalRoute : String -> Route
listingDetailsModalRoute listingUrlSlug =
  Search (Just listingUrlSlug)


decodeMarkerGroup : JD.Value -> Result String (List GoogleMaps.PropertyMarker)
decodeMarkerGroup payload =
  JD.decodeValue (JD.list GoogleMaps.propertyMarkerDecoder) payload
