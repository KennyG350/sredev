module MultiUnitList.Types exposing (Msg(..), Model, SocketResponse)


import Json.Encode as JE
import Ports.Dom as Dom


type alias Model = ()
type alias Bounds = JE.Value
type alias Topic = String
type alias Event = String
type alias Payload = JE.Value
type alias Selector = String


type Msg
  = HandleClick (Selector, Dom.HtmlElement, Dom.Event)
  | ReceiveWebsocketMessage (Topic, Event, Payload)
  | ReceiveBroadcast (String, Payload)
  | InnerHtmlReplaced Selector


type alias SocketResponse =
  { page : Int
  , total_results : Int
  , view : String
  }
