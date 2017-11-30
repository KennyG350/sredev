module FeedMaps.App exposing (main)


import Ports.Dom as Dom
import Ports.GoogleMaps as GoogleMaps
import Ports.GoogleMaps.Style as Style
import Ports.PubSub as PubSub
import FeedMaps.Types exposing (..)
import FeedMaps.Update exposing (update)
import FeedMaps.MapStyles exposing (mapStyles)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  { feeds = [] } !
  [ GoogleMaps.createMap (".elm-feed-map-continental-us", continentalUsMapOptions)
  , GoogleMaps.createMap (".elm-feed-map-hawaii", hawaiiMapOptions)
  , Dom.querySelector ".elm-feed-data"
  ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.querySelectorResponse QuerySelectorResponse
    , GoogleMaps.createMapFinished CreateMapFinished
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]


continentalUsMapOptions : GoogleMaps.CreateMapOptions
continentalUsMapOptions =
  { center = Just usaCenterLatLng
  , disableDefaultUI = Just True
  , mapTypeControlPosition = Nothing
  , mapTypeId = Nothing
  , maxZoom = Just 4
  , minZoom = Just 4
  , rotateControlPosition = Nothing
  , scrollWheel = Just False
  , signInControl = Just False
  , streetViewControlPosition = Nothing
  , styles = List.map Style.toJson mapStyles
  , zoom = Just 4
  , zoomControlPosition = Nothing
  }

hawaiiMapOptions : GoogleMaps.CreateMapOptions
hawaiiMapOptions =
  { center = Just hawaiiCenterLatLng
  , disableDefaultUI = Just True
  , mapTypeControlPosition = Nothing
  , mapTypeId = Nothing
  , maxZoom = Just 6
  , minZoom = Just 6
  , rotateControlPosition = Nothing
  , scrollWheel = Just False
  , signInControl = Just False
  , streetViewControlPosition = Nothing
  , styles = List.map Style.toJson mapStyles
  , zoom = Just 4
  , zoomControlPosition = Nothing
  }

hawaiiCenterLatLng : GoogleMaps.LatLng
hawaiiCenterLatLng =
  GoogleMaps.LatLng 20.712125 -157.478027

usaCenterLatLng : GoogleMaps.LatLng
usaCenterLatLng =
  GoogleMaps.LatLng 39.83333 -97.416666

