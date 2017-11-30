module BuyCalculator.Label.App exposing (main)


import Debounce
import Ports.PubSub as PubSub
import Ports.Dom as Dom
import BuyCalculator.Label.Types exposing (..)
import BuyCalculator.Label.Update exposing (update)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  { containerPosition = Nothing
  , resizeThrottleState = Debounce.init
  } !
  [ Dom.getNodePosition ".elm-buy-calculator-slider"
  , Dom.addEventListener ("window", "resize", Nothing)
  ]


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ Dom.nodePosition NodePosition
    , PubSub.receiveBroadcast ReceiveBroadcast
    , Dom.onResize OnResizeWindow
    ]
