module ContactForm.Types.UserEnteredFields exposing (..)


import Json.Encode as JE
import Json.Decode as JD


type alias UserEnteredFields =
  { firstName : String
  , lastName : String
  , email : String
  , phone : String
  , message : String
  }


decoder : JD.Decoder UserEnteredFields
decoder =
  JD.map5 UserEnteredFields
    (JD.field "first_name" JD.string)
    (JD.field "last_name" JD.string)
    (JD.field "email" JD.string)
    (JD.field "phone" JD.string)
    (JD.field "message" JD.string)


encode : UserEnteredFields -> JE.Value
encode { firstName, lastName, email, phone, message } =
  JE.object
    [ ("first_name", JE.string firstName)
    , ("last_name", JE.string lastName)
    , ("email", JE.string email)
    , ("phone", JE.string phone)
    , ("message", JE.string message)
    ]
