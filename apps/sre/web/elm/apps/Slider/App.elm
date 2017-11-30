module Slider.App exposing (main)


import Mouse
import Debounce
import Ports.Dom as Dom
import Slider.Update exposing (update)
import Slider.Types exposing (..)


main : Program Flags Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : Flags -> (Model, Cmd Msg)
init { containerSelector, knobSelector, rangeBarSelector } =
  { containerSelector = containerSelector
  , knobSelector = knobSelector
  , rangeBarSelector = rangeBarSelector
  , containerPosition = Nothing
  , initialBroadcastSent = False
  , dragState = NotDragging
  , knobBroadcastThrottleState = Debounce.init
  , resizeThrottleState = Debounce.init
  } !
  [ Dom.getNodePosition containerSelector
  , Dom.addEventListener (rangeBarSelector, "mousedown", Nothing)
  , Dom.addEventListener ("window", "resize", Nothing)
  , Dom.addEventListener (knobSelector, "mousedown", Nothing)
  , Dom.addEventListener (knobSelector, "touchstart", Nothing)
  , Dom.addEventListener (knobSelector, "touchmove", Nothing)
  , Dom.addEventListener (knobSelector, "touchend", Nothing)
  , Dom.addEventListener (rangeBarSelector, "touchstart", Nothing)
  , Dom.addEventListener (rangeBarSelector, "touchmove", Nothing)
  , Dom.addEventListener (rangeBarSelector, "touchend", Nothing)
  ]


subscriptions : Model -> Sub Msg
subscriptions { containerPosition, dragState } =
  Sub.batch
    [ Dom.nodePosition NodePosition
    , Dom.onResize OnResize
    , dragStateSubscriptions dragState
    ]


dragStateSubscriptions : DragState -> Sub Msg
dragStateSubscriptions dragState =
  case dragState of
    NotDragging ->
      Sub.batch
        [ Dom.onMousedown OnMouseDown
        , Dom.onTouchstart OnTouchStart
        ]

    MouseDragging ->
      Sub.batch
        [ Mouse.moves OnMouseMove
        , Mouse.ups OnMouseUp
        ]

    TouchDragging ->
      Sub.batch
        [ Dom.onTouchmove OnTouchMove
        , Dom.onTouchend OnTouchEnd
        ]
