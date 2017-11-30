module Filters.RangeSlider.Types exposing (..)


import Mouse
import Debounce exposing (Debounce)
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Filters.RangeSlider.Types.Knob exposing (Knob)


type alias Flags =
  { sliderSelector : String
  , innerBarSelector : String
  }


type alias Model =
  { sliderSelector : String
  , innerBarSelector : String
  , sliderPosition : Maybe Dom.Position
  , leftKnobPosition : Float
  , rightKnobPosition : Float
  , mouseDragging : Maybe Knob
  , touchDraggingLeft : Bool
  , touchDraggingRight : Bool
  , leftKnobThrottleState : Debounce Float
  , rightKnobThrottleState : Debounce Float
  , resizeThrottleState : Debounce ()
  }


type Msg
  = NodePosition (Dom.Selector, Dom.Position)
  | OnMouseDown (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | MouseMove Mouse.Position
  | EndMouseDragging Mouse.Position
  | OnTouchStart (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnTouchMove (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnTouchEnd (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | UpdateLeftKnob Float
  | UpdateRightKnob Float
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | ThrottleLeftKnobBroadcast Debounce.Msg
  | ThrottleRightKnobBroadcast Debounce.Msg
  | OnResize (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | ThrottleResize Debounce.Msg
