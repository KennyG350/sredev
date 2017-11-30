module UserActivityWorker.Types exposing (..)


import Ports.PubSub as PubSub
import Ports.LocalStorage as LocalStorage
import Ports.Websocket as Websocket
import Ports.Routing as Routing


type Msg
  = ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | ReceiveUserId (Maybe Int)
  | StorageGetItemResponse (LocalStorage.Key, LocalStorage.Value)
  | ReceivePendingFavorites (List String)
  | ReceivePendingListingView (List String)
  | WebsocketReceive (Websocket.Topic, Websocket.Event, Websocket.Payload)
  | UrlUpdate (Routing.Location)


type alias Model =
  { userId : Maybe UserId
  }


type alias UserId = Int
