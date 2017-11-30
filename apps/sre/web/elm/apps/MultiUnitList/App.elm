module MultiUnitList.App exposing (main)


import Platform
import Ports.Websocket as Websocket
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import MultiUnitList.Types exposing (..)
import MultiUnitList.Config exposing (..)
import MultiUnitList.Update exposing (update)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    }


init : (Model, Cmd Msg)
init =
  () !
  [ Dom.addClickListener ".elm-search-property-close"
  , Dom.addClickListener clickTargetSelector
  , Websocket.websocketListen (websocketTopic, websocketEventReceive)
  ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Websocket.websocketReceive ReceiveWebsocketMessage
    , PubSub.receiveBroadcast ReceiveBroadcast
    , Dom.innerHtmlReplaced InnerHtmlReplaced
    , Dom.onClick HandleClick
    ]
