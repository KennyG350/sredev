module ContactForm.Types exposing(..)


import Json.Encode as JE
import AppSwitch exposing (AppSwitch)
import Ports.Websocket as Websocket
import Ports.Routing as Routing
import Ports.LocalStorage as LocalStorage


type alias Selector = String


type Msg
  = HandleFormSubmit (Selector, JE.Value)
  | ValidateEmailPayload
  | ReceiveWebsocketMessage (Websocket.Topic, Websocket.Event, Websocket.Payload)
  | UrlUpdate Routing.Location
  | ReceiveUserId (Maybe Int)
  | StorageGetItemResponse (LocalStorage.Key, LocalStorage.Value)


type FormType
  = GenericContactForm
  | PropertyDetailsForm


type alias Flags =
  { forSpecificListing : Bool
  , formSelector : String
  }


type alias Model =
  { formType : FormType
  , formSelector : String
  , appSwitch : AppSwitch
  , userId : Maybe Int
  }
