module Filters.RangeSlider.Update exposing (update)


import Time
import Debounce
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Filters.RangeSlider.Helper exposing (leftKnobSelector, rightKnobSelector, knobToSelector)
import Filters.RangeSlider.Types exposing (..)
import Filters.RangeSlider.Types.Knob exposing (Knob(..), KnobPositionUpdate, encodeKnobPositionUpdate, decodeKnobPositionUpdate)


minKnobDistance : Float -- In percent of price range slider width
minKnobDistance = 0.05


knobUpdateBroadcastThrottle : Float -- In milliseconds
knobUpdateBroadcastThrottle = 30


resizeThrottle : Float -- In milliseconds
resizeThrottle = 750


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NodePosition (_, sliderPosition) ->
      { model | sliderPosition = Just sliderPosition } ! []

    OnMouseDown (selector, _, _) ->
      if selector == (leftKnobSelector model.sliderSelector) then
        { model | mouseDragging = Just LeftKnob } ! []

      else if selector == (rightKnobSelector model.sliderSelector) then
        { model | mouseDragging = Just RightKnob } ! []

      else
        model ! []

    MouseMove { x } ->
      case (model.mouseDragging, model.sliderPosition) of
        (Just LeftKnob, Just sliderPosition) ->
          update (UpdateLeftKnob <| knobPosition sliderPosition <| toFloat x) model

        (Just RightKnob, Just sliderPosition) ->
          update (UpdateRightKnob <| knobPosition sliderPosition <| toFloat x) model

        _ ->
          model ! []

    EndMouseDragging _ ->
      { model | mouseDragging = Nothing } ! []

    OnTouchStart (selector, _, _) ->
      if selector == (leftKnobSelector model.sliderSelector) then
        { model | touchDraggingLeft = True } ! []

      else if selector == (rightKnobSelector model.sliderSelector) then
        { model | touchDraggingRight = True } ! []

      else
        model ! []

    OnTouchMove (selector, _, { touchClientX }) ->
      case (touchClientX, model.sliderPosition) of
        (Just x, Just sliderPosition) ->
          if model.touchDraggingLeft && selector == (leftKnobSelector model.sliderSelector) then
            update (UpdateLeftKnob <| knobPosition sliderPosition x) model

          else if model.touchDraggingRight && selector == (rightKnobSelector model.sliderSelector) then
            update (UpdateRightKnob <| knobPosition sliderPosition x) model

          else
            model ! []

        _ ->
          model ! []

    OnTouchEnd (selector, _, _) ->
      if selector == (leftKnobSelector model.sliderSelector) then
        { model | touchDraggingLeft = False } ! []

      else if selector == (rightKnobSelector model.sliderSelector) then
        { model | touchDraggingRight = False } ! []

      else
        model ! []

    UpdateLeftKnob position ->
      let
        correctedPosition =
          position
          |> min (model.rightKnobPosition - minKnobDistance)
          |> max 0

        model_ = { model | leftKnobPosition = correctedPosition }

        (throttleState, throttleCmd) =
          Debounce.push (debounceConfig knobUpdateBroadcastThrottle ThrottleLeftKnobBroadcast) correctedPosition model.leftKnobThrottleState
      in
        { model_ | leftKnobThrottleState = throttleState } !
        [ throttleCmd
        , setKnobLeft model.sliderSelector LeftKnob correctedPosition
        , updateBarCss model_
        ]

    UpdateRightKnob position ->
      let
        correctedPosition =
          position
          |> max (model.leftKnobPosition + minKnobDistance)
          |> min 1

        model_ = { model | rightKnobPosition = correctedPosition }

        (throttleState, throttleCmd) =
          Debounce.push (debounceConfig knobUpdateBroadcastThrottle ThrottleRightKnobBroadcast) correctedPosition model.rightKnobThrottleState
      in
        { model_ | rightKnobThrottleState = throttleState } !
        [ throttleCmd
        , setKnobLeft model.sliderSelector RightKnob correctedPosition
        , updateBarCss model_
        ]

    ReceiveBroadcast ("updateKnobPosition", payload) ->
      case decodeKnobPositionUpdate payload of
        Ok { knob, position } ->
          case knob of
            LeftKnob ->
              update (UpdateLeftKnob position) model

            RightKnob ->
              update (UpdateRightKnob position) model

        Err _ ->
          model ! []

    ThrottleLeftKnobBroadcast throttleMsg ->
      let
        (throttleState, cmd) =
          Debounce.update
            (debounceConfig knobUpdateBroadcastThrottle ThrottleLeftKnobBroadcast)
            (Debounce.takeLast <| broadcastKnobPositionUpdate LeftKnob)
            throttleMsg
            model.leftKnobThrottleState
      in
        ({ model | leftKnobThrottleState = throttleState }, cmd)

    ThrottleRightKnobBroadcast throttleMsg ->
      let
        (throttleState, cmd) =
          Debounce.update
            (debounceConfig knobUpdateBroadcastThrottle ThrottleRightKnobBroadcast)
            (Debounce.takeLast <| broadcastKnobPositionUpdate RightKnob)
            throttleMsg
            model.rightKnobThrottleState
      in
        ({ model | rightKnobThrottleState = throttleState }, cmd)

    OnResize ("window", _, _) ->
      let
        (throttleState, throttleCmd) =
          Debounce.push
            (debounceConfig resizeThrottle ThrottleResize) () model.resizeThrottleState
      in
        ( { model | resizeThrottleState = throttleState }
        , throttleCmd
        )

    ThrottleResize throttleMsg ->
      let
        (throttleState, cmd) =
          Debounce.update
            (debounceConfig resizeThrottle ThrottleResize)
            (Debounce.takeLast <| always <| Dom.getNodePosition model.sliderSelector)
            throttleMsg
            model.resizeThrottleState
      in
        ({ model | resizeThrottleState = throttleState }, cmd)

    _ ->
      model ! []


broadcastKnobPositionUpdate : Knob -> Float -> Cmd Msg
broadcastKnobPositionUpdate knob position =
  PubSub.broadcast
    ( "knobPositionUpdated"
    , encodeKnobPositionUpdate <| KnobPositionUpdate knob position
    )


knobPosition : Dom.Position -> Float -> Float
knobPosition sliderPosition knobX =
  let
    { left, right } = sliderPosition
  in
    (knobX - left) / (right - left)


setKnobLeft : String -> Knob -> Float -> Cmd Msg
setKnobLeft sliderSelector knob position =
  Dom.setCssProperty
    ( knobToSelector sliderSelector knob
    , "left"
    , floatToCssPercent position
    )


updateBarCss : Model -> Cmd Msg
updateBarCss { innerBarSelector, leftKnobPosition, rightKnobPosition } =
  Cmd.batch
    [ Dom.setCssProperty
        ( innerBarSelector
        , "left"
        , floatToCssPercent leftKnobPosition
        )
    , Dom.setCssProperty
        ( innerBarSelector
        , "width"
        , floatToCssPercent (rightKnobPosition - leftKnobPosition)
        )
    ]


{-| Convert a Float between 0 and 1 to a percentage.

    floatToCssPercent 0.1 == "10%"
    floatToCssPercent 1 == "100%"
    floatToCssPercent 0 == "0%"
-}
floatToCssPercent : Float -> String
floatToCssPercent position =
  position * 100
  |> toString
  |> (flip String.append) "%"


debounceConfig : Float -> (Debounce.Msg -> Msg) -> Debounce.Config Msg
debounceConfig milliseconds msg =
  { strategy = Debounce.soon (milliseconds * Time.millisecond)
  , transform = msg
  }
