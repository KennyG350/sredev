module ListingList.App exposing (main)


import Ports.Dom as Dom
import Ports.Websocket as Websocket
import Ports.PubSub as PubSub
import ListingList.Types exposing (..)
import ListingList.Update exposing (update, clickListeners)


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
  (Websocket.websocketListen ("listing_list", "receive_listing_list") :: clickListeners)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Websocket.websocketReceive ReceiveWebsocketMessage
    , Dom.onClick HandleClick
    , Dom.innerHtmlReplaced InnerHtmlReplaced
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]
