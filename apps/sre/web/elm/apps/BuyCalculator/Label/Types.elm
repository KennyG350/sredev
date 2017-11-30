module BuyCalculator.Label.Types exposing (..)


import Debounce exposing (Debounce)
import Ports.Dom as Dom
import Ports.PubSub as PubSub


type alias Model =
  { containerPosition : Maybe Dom.Position
  , resizeThrottleState : Debounce ()
  }


type Msg
  = QuerySelectorResponse (Dom.Selector, Dom.HtmlElement)
  | NodePosition (Dom.Selector, Dom.Position)
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | OnResizeWindow (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | ThrottleResize Debounce.Msg
