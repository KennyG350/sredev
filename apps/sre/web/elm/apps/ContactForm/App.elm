module ContactForm.App exposing (main)


import AppSwitch
import Ports.Websocket as Websocket
import Ports.Dom as Dom
import Ports.Routing as Routing
import Ports.Auth as Auth
import Ports.LocalStorage as LocalStorage
import ContactForm.Types exposing (..)
import ContactForm.Update exposing (update, successEvent)


main : Program Flags Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = AppSwitch.subscriptions .appSwitch subscriptions
    , update = update
    }


init : Flags -> (Model, Cmd Msg)
init flags =
  let
    formType = formTypeFromFlags flags
  in
    { formType = formType
    , formSelector = flags.formSelector
    , appSwitch = AppSwitch.On
    , userId = Nothing
    } !
    [ Dom.addSubmitListener (flags.formSelector, formFields formType)
    , Websocket.websocketListen ("form", successEvent formType)
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onSubmit HandleFormSubmit
    , Websocket.websocketReceive ReceiveWebsocketMessage
    , Routing.urlUpdate UrlUpdate
    , Auth.userId ReceiveUserId
    , LocalStorage.storageGetItemResponse StorageGetItemResponse
    ]


formFields : FormType -> List String
formFields formType =
  case formType of
    PropertyDetailsForm ->
      "listing_id"::genericContactFormFields

    GenericContactForm ->
      genericContactFormFields


genericContactFormFields : List String
genericContactFormFields =
  [ "first_name", "last_name", "message", "email", "phone" ]


formTypeFromFlags : Flags -> FormType
formTypeFromFlags { forSpecificListing } =
  if forSpecificListing then
    PropertyDetailsForm

  else
    GenericContactForm
