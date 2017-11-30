module BuyCalculator.App exposing (main)


import Maybe
import Array exposing (Array)
import Ports.PubSub as PubSub
import Ports.Dom as Dom
import NumberFormatter
import BuyCalculator.Types exposing (..)
import BuyCalculator.Update exposing (update)


main : Program Flags Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = always (PubSub.receiveBroadcast ReceiveBroadcast)
    , update = update
    }


init : Flags -> (Model, Cmd Msg)
init { sliderOptions, rebateMultiplier } =
  { sliderOptions = sliderOptions
  , sliderOptionsLength = Array.length sliderOptions
  , rebateMultiplier = rebateMultiplier
  } !
  [ Dom.innerHtml
      ( ".elm-buy-calculator-limit-min"
      , sliderOptions
        |> Array.get 0
        |> Maybe.withDefault 0
        |> NumberFormatter.intToCurrency
      )
  , Dom.innerHtml
      ( ".elm-buy-calculator-limit-max"
      , sliderOptions
        |> Array.get ((Array.length sliderOptions) - 1)
        |> Maybe.withDefault 0
        |> NumberFormatter.intToCurrency
      )
  ]
