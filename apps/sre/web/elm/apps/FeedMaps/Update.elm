module FeedMaps.Update exposing (update)


import Json.Decode as JD
import Json.Encode as JE
import Ports.Dom as Dom
import Ports.GoogleMaps as GoogleMaps
import Ports.PubSub as PubSub
import RouteHelper
import FeedMaps.Types exposing (..)
import FeedMaps.Types.Feed as Feed


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    QuerySelectorResponse (".elm-feed-data", { data }) ->
      case Dom.dataAttribute data "feeds" of
        Just feeds ->
          feeds
          |> JD.decodeString (JD.list Feed.decoder)
          |> Result.toMaybe
          |> Maybe.withDefault []
          |> List.map Feed.toMarker
          |> \markers ->
               Cmd.batch
                 [ GoogleMaps.addMarkers (".elm-feed-map-continental-us", markers)
                 , GoogleMaps.addMarkers (".elm-feed-map-hawaii", markers)
                 ]
          |> \cmd -> (model, cmd)

        Nothing ->
          model ! []

    CreateMapFinished ".elm-feed-map-continental-us" ->
      ( model
      , GoogleMaps.fitBounds (".elm-feed-map-continental-us", continentalUnitedStatesBounds)
      )

    CreateMapFinished ".elm-feed-map-hawaii" ->
      ( model
      , GoogleMaps.fitBounds (".elm-feed-map-hawaii", hawaiiStateBounds)
      )

    -- We passed bounds as name, so we can use it directly to create a search
    ReceiveBroadcast ("markerClicked", markerName) ->
      markerName
      |> JD.decodeValue JD.string
      |> Result.toMaybe
      |> Maybe.map goToBuyCalc
      |> Maybe.withDefault Cmd.none
      |> \cmd -> (model, cmd)

    _ ->
      model ! []


continentalUnitedStatesBounds : GoogleMaps.LatLngBounds
continentalUnitedStatesBounds =
  ( GoogleMaps.LatLng 24.396308 -124.848974
  , GoogleMaps.LatLng 49.384358 -66.885444
  )

hawaiiStateBounds : GoogleMaps.LatLngBounds
hawaiiStateBounds =
  ( GoogleMaps.LatLng 18.716171 -160.048828
  , GoogleMaps.LatLng 22.326894 -154.940186
  )


goToBuyCalc : String ->  Cmd Msg
goToBuyCalc name =
  Cmd.batch
    [ Dom.setProperty (".elm-buy-calculator-geosuggest-input input", "value", JE.string name)
    , Dom.windowScrollToSelector ".elm-buy-anchor"
    , PubSub.broadcast ("feedMapPinClicked", JE.string name)
    ]


boundsStringToSearchCmd : String -> Cmd Msg
boundsStringToSearchCmd bounds =
  Cmd.batch
    [ RouteHelper.newUrl ("/properties?bounds=" ++ bounds)
    , RouteHelper.reload
    ]
