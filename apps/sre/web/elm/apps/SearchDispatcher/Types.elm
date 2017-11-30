module SearchDispatcher.Types exposing (..)


import Ports.Routing as Routing
import Ports.PubSub as PubSub
import Route exposing (Route)
import SearchParameters exposing (SearchParameters)


type alias ListingUrl = String


type Msg
  = ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | UrlUpdate Routing.Location


type alias Model =
  { searchParameters : SearchParameters
  , route : Maybe Route
  }
