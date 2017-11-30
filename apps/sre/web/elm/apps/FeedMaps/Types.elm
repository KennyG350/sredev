module FeedMaps.Types exposing (..)


import Ports.Dom as Dom
import Ports.PubSub as PubSub


type alias Feed =
  { searchBounds : String
  , markerLat : Float
  , markerLng : Float
  }


type alias Model =
  { feeds : List Feed
  }


type Msg
  = QuerySelectorResponse (Dom.Selector, Dom.HtmlElement)
  | CreateMapFinished Dom.Selector
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
