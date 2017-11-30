module ListingList.Types exposing (..)


import Json.Encode
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Ports.Routing as Routing


type alias Selector = String


type Msg
  = ReceiveWebsocketMessage (String, String, Json.Encode.Value)
  | HandleClick (Selector, Dom.HtmlElement, Dom.Event)
  | RequestListingList
  | InnerHtmlReplaced String
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | UrlUpdate Routing.Location


type alias Model = ()


type alias SocketResponse =
  { page : Int
  , total_results : Int
  , view : String
  }
