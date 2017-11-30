module SearchMap.Update exposing (update)


import List
import String
import Maybe exposing (withDefault, andThen)
import Maybe.Extra as ME
import Result exposing (toMaybe)
import Json.Encode as JE
import Json.Decode as JD
import UrlQueryParser as UQP
import Ports.GoogleMaps as GoogleMaps
import Ports.Websocket as Websocket
import Ports.PubSub as PubSub
import SearchParameters exposing (SearchParameters)
import SearchMap.Types exposing (..)


type alias Markers =
  { listings : List Marker
  }


type alias Marker =
  { latitude : String
  , longitude : String
  , price : String
  , url : String
  }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OnBoundsChanged (".elm-google-map", newBounds) ->
      case model.nextBoundsChangeSource of
        User ->
          ( { model | currentBounds = Just newBounds }
          , PubSub.broadcast ("mapBoundsChanged", JE.string newBounds)
          )

        Elm ->
          { model | currentBounds = Just newBounds, nextBoundsChangeSource = User } ! []

    ReceiveBroadcast ("searchParametersInitialized", searchParameters) ->
      searchParameters
      |> SearchParameters.fromJson
      |> initialFitBoundsCmds
      |> \cmds ->
           { model | nextBoundsChangeSource = Elm } ! cmds

    ReceiveBroadcast ("performNewMapSearch", searchParameters) ->
      searchParameters
      |> SearchParameters.fromJson
      |> requestMapData
      |> \cmd -> ({ model | awaitingNewResults = True }, cmd)

    ReceiveWebsocketMessage ("map", "receive_map_data", payload) ->
      let
        cmd =
          case decodeMarkers payload of
            Ok markers ->
              GoogleMaps.addPropertyMarkers (".elm-google-map", markerConfigs markers)

            Err error ->
              Cmd.none
      in
        ( { model | awaitingNewResults = False }
        , cmd
        )

    ReceiveBroadcast ("fitMapToNewBounds", bounds) ->
      case JD.decodeValue GoogleMaps.latLngBoundsDecoder bounds of
        Ok bounds_ ->
          ( { model
            | currentBounds = Just (GoogleMaps.latLngBoundsToString bounds_)
            , nextBoundsChangeSource = Elm
            }
          , GoogleMaps.fitBounds
              ( ".elm-google-map"
              , GoogleMaps.slightlyShrinkBounds bounds_
              )
          )

        Err _ ->
          model ! []

    _ ->
      model ! []


filterParams : List String
filterParams =
  [ "bathrooms"
  , "bedrooms"
  , "bounds"
  , "exclude_condo"
  , "exclude_house"
  , "exclude_townhouse"
  , "home_size_min"
  , "location"
  , "lot_size_min"
  , "page"
  , "price_max"
  , "price_min"
  , "year_built_min"
  ]

requestMapData : SearchParameters -> Cmd Msg
requestMapData params =
  Websocket.websocketSend
    ( "map"
    , "request_map_data"
    , JE.object
        [ ( "filters"
          , params
            |> SearchParameters.toQueryParams
            |> UQP.toJsonObject filterParams
          )
        ]
    )


decodeMarkers : JD.Value -> Result String Markers
decodeMarkers =
  JD.decodeValue <| JD.map Markers (JD.field "listings" (JD.list markerDecoder))


markerDecoder : JD.Decoder Marker
markerDecoder =
  JD.map4 Marker
    (JD.field "latitude" JD.string)
    (JD.field "longitude" JD.string)
    (JD.field "price" JD.string)
    (JD.field "url" JD.string)


markerConfigs : Markers -> List GoogleMaps.PropertyMarker
markerConfigs =
  .listings
  >> List.map markerToPropertyMarker
  >> List.filter ME.isJust
  >> List.map (withDefault GoogleMaps.emptyPropertyMarker)


markerToPropertyMarker : Marker -> Maybe GoogleMaps.PropertyMarker
markerToPropertyMarker marker =
  let
    lat = String.toFloat marker.latitude
    lng = String.toFloat marker.longitude
    price = String.toFloat marker.price
  in
    case (lat, lng, price) of
      (Ok lat_, Ok lng_, Ok price_) ->
        Just
          <| GoogleMaps.PropertyMarker
               (GoogleMaps.LatLng lat_ lng_)
               price_
               marker.url

      _ ->
        Nothing


initialFitBoundsCmds : SearchParameters -> List (Cmd Msg)
initialFitBoundsCmds params =
  [ case params.bounds of
      Just bounds ->
        GoogleMaps.fitBounds (".elm-google-map", GoogleMaps.slightlyShrinkBounds bounds)

      Nothing ->
        Cmd.none

  , requestMapData params
  ]
