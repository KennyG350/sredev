module Filters.RangeSlider.App exposing (main)


import Mouse
import Debounce
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Filters.RangeSlider.Types exposing (..)
import Filters.RangeSlider.Helper exposing (rightKnobSelector, leftKnobSelector)
import Filters.RangeSlider.Update exposing (update)


main : Program Flags Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : Flags -> (Model, Cmd Msg)
init { sliderSelector, innerBarSelector } =
  let
    leftKnob = leftKnobSelector sliderSelector
    rightKnob = rightKnobSelector sliderSelector
  in
    { sliderSelector = sliderSelector
    , innerBarSelector = innerBarSelector
    , sliderPosition = Nothing
    , leftKnobPosition = 0
    , rightKnobPosition = 1
    , mouseDragging = Nothing
    , touchDraggingLeft = False
    , touchDraggingRight = False
    , leftKnobThrottleState = Debounce.init
    , rightKnobThrottleState = Debounce.init
    , resizeThrottleState = Debounce.init
    } !
    [ Dom.getNodePosition sliderSelector
    , Dom.addEventListener (leftKnob, "mousedown", Nothing)
    , Dom.addEventListener (leftKnob, "touchstart", Nothing)
    , Dom.addEventListener (leftKnob, "touchmove", Nothing)
    , Dom.addEventListener (leftKnob, "touchend", Nothing)
    , Dom.addEventListener (rightKnob, "mousedown", Nothing)
    , Dom.addEventListener (rightKnob, "touchstart", Nothing)
    , Dom.addEventListener (rightKnob, "touchmove", Nothing)
    , Dom.addEventListener (rightKnob, "touchend", Nothing)
    , Dom.addEventListener ("window", "resize", Nothing)
    ]


subscriptions : Model -> Sub Msg
subscriptions { mouseDragging } =
  let
    mouseMoveListener =
      case mouseDragging of
        Just knob ->
          [ Mouse.moves MouseMove
          , Mouse.ups EndMouseDragging
          ]

        Nothing ->
          []
  in
    Sub.batch <|
      List.append
        mouseMoveListener
        [ Dom.nodePosition NodePosition
        , Dom.onMousedown OnMouseDown
        , Dom.onTouchstart OnTouchStart
        , Dom.onTouchmove OnTouchMove
        , Dom.onTouchend OnTouchEnd
        , Dom.onResize OnResize
        , PubSub.receiveBroadcast ReceiveBroadcast
        ]
