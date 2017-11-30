module Slider.Types exposing (..)


import Mouse
import Debounce exposing (Debounce)
import Ports.Dom as Dom
import Slider.Types.KnobPosition exposing (KnobPosition)


type alias XCoordinate = Float


type alias Model =
  { containerSelector : String
  , knobSelector : String
  , rangeBarSelector : String
  , containerPosition : Maybe Dom.Position
  , initialBroadcastSent : Bool
  , dragState : DragState
  , knobBroadcastThrottleState : Debounce KnobPosition
  , resizeThrottleState : Debounce ()
  }


type alias Flags =
  { containerSelector : String
  , knobSelector : String
  , rangeBarSelector : String
  }


type DragState
  = NotDragging
  | MouseDragging
  | TouchDragging


type Msg
  = NodePosition (Dom.Selector, Dom.Position)
  | OnResize (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnMouseDown (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnMouseMove Mouse.Position
  | OnMouseUp Mouse.Position
  | OnTouchStart (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnTouchMove (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnTouchEnd (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | ThrottleResize Debounce.Msg
  | ThrottleKnobBroadcast Debounce.Msg
  | UpdateKnobPosition XCoordinate


type NodePositionResponse
  = GetKnobPosition Dom.Selector
  | BroadcastKnobPosition Dom.Position Dom.Position -- container-position, knob-position
