module ListingDetailsModal.Types exposing (..)


import Json.Encode
import Ports.Dom as Dom
import Ports.Routing as Routing


type alias RawHtml = String
type alias Url = String
type alias Payload = Json.Encode.Value
type alias Topic = String
type alias Event = String


type Msg
  = CloseModal
  | HandleClick (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | QuerySelectorResponse (Dom.Selector, Dom.HtmlElement)
  | InnerHtmlReplaced Dom.Selector
  | LoadModal Url
  | ReceiveWebsocketMessage (Topic, Event, Payload)
  | ReceiveBroadcast (String, Payload)
  | UrlUpdate Routing.Location


type alias Model =
  { location : Routing.Location
  , view : Maybe String
  }
