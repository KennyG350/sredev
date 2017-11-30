module SearchMap.App exposing (main)


import Ports.GoogleMaps as GoogleMaps
import Ports.Websocket as Websocket
import Ports.PubSub as PubSub
import Config
import SearchMap.Types exposing (..)
import SearchMap.Update exposing (update)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  { awaitingNewResults = False
  , currentBounds = Nothing
  , nextBoundsChangeSource = User
  } !
  [ GoogleMaps.createMap
      ( ".elm-google-map"
      , { center = Nothing
        , disableDefaultUI = Nothing
        , mapTypeControlPosition = Nothing
        , mapTypeId = Nothing
        , maxZoom = Nothing
        , minZoom = Nothing
        , rotateControlPosition = Nothing
        , scrollWheel = Nothing
        , signInControl = Nothing
        , streetViewControlPosition = Nothing
        , styles = Config.defaultMapStyles
        , zoom = Just 9
        , zoomControlPosition = Nothing
        }
      )
  , Websocket.websocketListen ("map", "receive_map_data")
  ]


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ GoogleMaps.createMapFinished OnCreateMapFinished
    , GoogleMaps.idle OnBoundsChanged
    , Websocket.websocketReceive ReceiveWebsocketMessage
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]
