module BuyCalculator.Update exposing (update)


import Array exposing (Array)
import Json.Encode as JE
import Json.Decode as JD
import NumberFormatter
import Ports.PubSub as PubSub
import Ports.Dom as Dom
import BuyCalculator.Types exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveBroadcast (message, position) ->
      if message == "sliderKnobPositionUpdated" || message == "sliderKnobPositionInitialized" then
        case JD.decodeValue JD.float position of
          Ok position ->
            position
            |> positionToPrice model.sliderOptions model.sliderOptionsLength
            |> priceToCmd model.rebateMultiplier
            |> \cmd -> (model, cmd)

          Err _ ->
            model ! []

      else
        model ! []


positionToPrice : SliderOptions -> Int -> Float -> Int
positionToPrice options optionsLength position =
  optionsLength
  |> toFloat
  |> (*) position
  |> \index -> index - position -- Little math trick to ensure neither end of the slider goes to 0
  |> round
  |> \index -> Array.get index options
  |> Maybe.withDefault 0


priceToCmd : Float -> Int -> Cmd Msg
priceToCmd rebateMultiplier price =
  Cmd.batch
    [ Dom.innerHtml
        ( ".elm-buy-calculator-purchase-price"
        , NumberFormatter.intToCurrency price
        )
    , Dom.innerHtml
        ( ".elm-buy-calculator-estimated-rebate"
        , price
          |> toFloat
          |> \p -> p * rebateMultiplier
          |> floor
          |> NumberFormatter.intToCurrency
        )
    , PubSub.broadcast ("buyCalculatorPriceUpdated", JE.int price)
    ]
