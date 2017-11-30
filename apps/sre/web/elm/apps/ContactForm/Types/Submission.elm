module ContactForm.Types.Submission exposing (..)


import Json.Encode as JE
import Json.Decode as JD
import ContactForm.Types exposing (FormType(..))
import ContactForm.Types.UserEnteredFields as UserEnteredFields exposing (..)


type alias ListingId = String


type Submission
  = GenericContactFormSubmission UserEnteredFields
  | PropertyDetailsFormSubmission ListingId UserEnteredFields


toUserEnteredFields : Submission -> UserEnteredFields
toUserEnteredFields submission =
  case submission of
    GenericContactFormSubmission userEnteredFields ->
      userEnteredFields

    PropertyDetailsFormSubmission listingId userEnteredFields ->
      userEnteredFields


toFormType : Submission -> FormType
toFormType submission =
  case submission of
    GenericContactFormSubmission _ ->
      GenericContactForm

    PropertyDetailsFormSubmission _ _ ->
      PropertyDetailsForm


encode : Submission -> JE.Value
encode submission =
  case submission of
    GenericContactFormSubmission { firstName, lastName, email, phone, message } ->
      JE.object
        [ ("first_name", JE.string firstName)
        , ("last_name", JE.string lastName)
        , ("email", JE.string email)
        , ("phone", JE.string phone)
        , ("message", JE.string message)
        ]

    PropertyDetailsFormSubmission listingId { firstName, lastName, email, phone, message } ->
      JE.object
        [ ("first_name", JE.string firstName)
        , ("last_name", JE.string lastName)
        , ("email", JE.string email)
        , ("phone", JE.string phone)
        , ("message", JE.string message)
        , ("listing_id", JE.string listingId)
        ]


decode : FormType -> JE.Value -> Result String Submission
decode formType jsonValue =
  case JD.decodeValue UserEnteredFields.decoder jsonValue of
    Ok userEnteredFields ->
      case formType of
        GenericContactForm ->
          Ok (GenericContactFormSubmission userEnteredFields)

        PropertyDetailsForm ->
          case JD.decodeValue (JD.field "listing_id" JD.string) jsonValue of
            Ok listingId ->
              Ok (PropertyDetailsFormSubmission listingId userEnteredFields)

            Err error ->
              Err error

    Err error ->
      Err error
