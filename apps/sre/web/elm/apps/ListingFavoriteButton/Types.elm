module ListingFavoriteButton.Types exposing (..)


import Ports.Dom as Dom
import Ports.PubSub as PubSub


type Msg
  = OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | ReceiveUserId (Maybe UserId)
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | FavoriteListing String
  | UnfavoriteListing String


type alias Model =
  { userId : Maybe UserId
  , containerSelector : String
  }


type alias UserId = Int
type alias Selector = String


type alias Flags =
  { containerSelector : String
  }
