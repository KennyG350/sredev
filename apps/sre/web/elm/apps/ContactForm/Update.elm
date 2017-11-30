module ContactForm.Update exposing (update, successEvent)

import Json.Encode as JE
import Json.Decode as JD
import Validation
import AppSwitch
import Ports.Dom as Dom
import Ports.Websocket as Websocket
import Ports.LocalStorage as LocalStorage
import Route exposing (Route(..))
import Config
import ContactForm.Types exposing (..)
import ContactForm.Types.Submission as Submission exposing (..)
import ContactForm.Types.UserEnteredFields as UserEnteredFields exposing (UserEnteredFields)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveUserId userId ->
      ( { model | userId = userId }
      , case userId of
          Just userId_ ->
            Cmd.none

          Nothing ->
            LocalStorage.storageGetItem Config.contactFormLocalStorageKey
      )

    -- If user is not logged in, previous contact form submission was requested. That's the only way to arrive here.
    StorageGetItemResponse (_, rawPayload) ->
      rawPayload
      |> JD.decodeValue UserEnteredFields.decoder
      |> Result.toMaybe
      |> Maybe.map (populateStoredFormDataCmd model.formSelector)
      |> Maybe.withDefault Cmd.none
      |> \cmd -> (model, cmd)

    HandleFormSubmit (_, rawPayload) ->
      rawPayload
      |> Submission.decode model.formType
      |> Result.toMaybe
      |> Maybe.map (submissionToCmds model.formSelector model.userId)
      |> Maybe.withDefault []
      |> \cmds -> model ! cmds

    ReceiveWebsocketMessage ("form", event, _) ->
      if event == (successEvent model.formType) then
        ( model
        , Dom.innerHtml
            ( model.formSelector
            , "<p>Your message has been received. An agent will contact you at the email address provided.</p>"
            )
        )

      else
        model ! []

    UrlUpdate location ->
      case Route.fromLocation location of
        Just (Search (Just listingSlug)) ->
          model ! []

        _ ->
          -- We're routing away from the listing modal; shut off app so it doesn't respond to other forms' submission messages
          { model | appSwitch = AppSwitch.Off } ! []

    _ ->
      model ! []


populateStoredFormDataCmd : String -> UserEnteredFields -> Cmd Msg
populateStoredFormDataCmd formSelector { firstName, lastName, email, phone } =
  Cmd.batch
    [ Dom.setProperty (formSelector ++ " #first_name", "value", JE.string firstName)
    , Dom.setProperty (formSelector ++ " #last_name", "value", JE.string lastName)
    , Dom.setProperty (formSelector ++ " #email", "value", JE.string email)
    , Dom.setProperty (formSelector ++ " #phone", "value", JE.string phone)
    ]


submissionToCmds : String -> Maybe Int -> Submission -> List (Cmd Msg)
submissionToCmds formSelector userId submission =
  case validateSubmission submission of
    Ok () ->
      [ Websocket.websocketSend
          ( "form"
          , submission
            |> Submission.toFormType
            |> submitEvent
          , Submission.encode submission
          )
      , case userId of
          Just _ ->
            Cmd.none

          Nothing ->
            LocalStorage.storageSetItem
              ( Config.contactFormLocalStorageKey
              , submission
                |> Submission.toUserEnteredFields
                |> UserEnteredFields.encode
              )
      , Dom.innerHtml (formSelector, "<p style='text-align:center;'>...</p>")
      ]

    Err _ ->
      [ Dom.innerHtml
          ( ".form-submit-error"
          , "<p style='color:red;text-align:center;padding-top:20px'>Please fill out all form fields</p>"
          )
      ]


validateSubmission : Submission -> Result (List String) ()
validateSubmission submission =
  submission
  |> Submission.toUserEnteredFields
  |> \fields ->
       Validation.checkEmptyFields
         [ ("first_name", fields.firstName)
         , ("last_name", fields.lastName)
         , ("email", fields.email)
         , ("phone", fields.phone)
         , ("message", fields.message)
         ]


submitEvent : FormType -> String
submitEvent formType =
  case formType of
    GenericContactForm ->
      "submit_form"

    PropertyDetailsForm ->
      "submit_property_details_form"


successEvent : FormType -> String
successEvent formType =
  case formType of
    GenericContactForm ->
      "form_submitted"

    PropertyDetailsForm ->
      "property_details_form_submitted"
