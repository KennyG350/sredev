module SearchMap.Types exposing (..)


import Json.Encode as JE
import Ports.PubSub as PubSub


type alias Selector = String
type alias BoundsUrlValue = String
type alias Topic = String
type alias Event = String
type alias Payload = JE.Value


type alias Model =
  { awaitingNewResults : Bool
  , currentBounds : Maybe String
  , nextBoundsChangeSource : BoundsChangeSource
  }


type Msg
  = OnCreateMapFinished Selector
  | OnBoundsChanged (Selector, BoundsUrlValue)
  | PerformNewSearch
  | ReceiveWebsocketMessage (Topic, Event, Payload)
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)


type BoundsChangeSource
  = Elm
  | User
