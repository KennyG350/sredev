module SaveSearch.Types exposing (..)

import Json.Encode
import Ports.Dom as Dom
import Ports.Routing as Routing

type alias Selector = String
type alias UserId = Int
type alias QuerySearch = String

type alias SocketResponse =
  { searchName : String
  }

type alias ListingListResponse =
  { savedSearch : Maybe SavedSearch
  }


type alias SavedSearch =
  { name : String
  , id_ : Int
  }


type alias Model =
  { userId : Maybe UserId
  , searchParams : QuerySearch
  }

type Msg
  = HandleClick (Selector, Dom.HtmlElement, Dom.Event)
  | ReceiveUserId (Maybe UserId)
  | UrlUpdate Routing.Location
  | ReceiveWebsocketMessage (String, String, Json.Encode.Value)
