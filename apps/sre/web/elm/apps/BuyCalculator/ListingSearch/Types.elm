module BuyCalculator.ListingSearch.Types exposing (..)


import Json.Decode as JD
import Debounce exposing (Debounce)
import Ports.PubSub as PubSub
import Ports.Websocket as Websocket
import Ports.Dom as Dom


type alias Model =
  { bounds : Maybe String
  , latitude : Maybe Float
  , longitude : Maybe Float
  , location : Maybe String
  , throttleState : Debounce Float
  , lastSearch : Maybe SearchParams
  , price : Float
  }


type Msg
  = ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | QuerySelectorResponse (Dom.Selector, Dom.HtmlElement)
  | WebsocketReceive (Websocket.Topic, Websocket.Event, Websocket.Payload)
  | ThrottleListingRequests Debounce.Msg
  | RequestNewListings Float


type alias SearchParams =
  { bounds : String
  , location : String
  , priceMin : Maybe Float
  , priceMax : Maybe Float
  }


searchParamsDecoder : JD.Decoder SearchParams
searchParamsDecoder =
  JD.map4 SearchParams
    (JD.field "bounds" JD.string)
    (JD.field "location" JD.string)
    (JD.field "priceMin" <| JD.maybe JD.float)
    (JD.field "priceMax" <| JD.maybe JD.float)
