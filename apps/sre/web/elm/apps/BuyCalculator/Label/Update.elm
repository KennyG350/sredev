module BuyCalculator.Label.Update exposing (update)


import Time
import Json.Decode as JD
import Debounce
import Ports.Dom as Dom
import Slider.Types.KnobPosition as KnobPosition
import BuyCalculator.Label.Types exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NodePosition (".elm-buy-calculator-slider", position) ->
      { model | containerPosition = Just position } ! []

    ReceiveBroadcast ("sliderKnobPositionInitialized", payload) -> -- Handle price init like update
      update (ReceiveBroadcast ("sliderKnobPositionUpdated", payload)) model

    ReceiveBroadcast ("sliderKnobPositionUpdated", payload) ->
      case (JD.decodeValue JD.float payload, model.containerPosition) of
        (Ok position, Just containerPosition) ->
          let
            minPosition = minimumPosition containerPosition
            maxPosition = 1 - minPosition
          in
            position
            |> max minPosition
            |> min maxPosition
            |> KnobPosition.fromFloat
            |> KnobPosition.toCssPercent
            |> \l ->
                 ( model
                 , Dom.setCssProperty (".elm-buy-calculator-slider-label", "left", l)
                 )

        _ ->
          model ! []

    OnResizeWindow _ ->
      let
        (throttleState, cmd) = Debounce.push resizeDebounceConfig () model.resizeThrottleState
      in
        ({ model | resizeThrottleState = throttleState }, cmd)

    ThrottleResize throttleMsg ->
      let
        (throttleState, cmd) =
          Debounce.update resizeDebounceConfig
            (Debounce.takeLast <| always getNodePositionCmd)
            throttleMsg
            model.resizeThrottleState
      in
        ({ model | resizeThrottleState = throttleState }, cmd)

    _ ->
      model ! []


minimumPosition : Dom.Position -> Float
minimumPosition { left, right } =
  halfLabelWidth / (right - left)


halfLabelWidth : Float
halfLabelWidth = 55


getNodePositionCmd : Cmd Msg
getNodePositionCmd =
  Dom.getNodePosition ".elm-buy-calculator-slider"


resizeDebounceConfig : Debounce.Config Msg
resizeDebounceConfig =
  { strategy = Debounce.soon (750 * Time.millisecond)
  , transform = ThrottleResize
  }
