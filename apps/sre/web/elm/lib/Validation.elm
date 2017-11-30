module Validation exposing (..)

import String
import Result
import Regex

type alias FirstName = String
type alias LastName = String
type alias Message = String
type alias PhoneNumber = String
type alias FieldName = String
type alias FieldNamePair = (FieldName, String)


isEmpty : FieldNamePair -> Result String ()
isEmpty (fieldName, field) =
  case String.isEmpty field of
    True ->
      Err (fieldName ++ " was empty")

    False ->
      Ok ()


runValidation : (a -> Result String b) -> List String -> List a ->  Result (List String) ()
runValidation validateValue errors fieldNamePairs =
  case fieldNamePairs of
    [] ->
      if (List.length errors) == 0 then
        Ok ()
      else
        Err errors

    (fieldNamePair::rest) ->
      case validateValue fieldNamePair of
        Ok _ ->
          runValidation validateValue errors rest

        Err reason ->
          runValidation validateValue (reason::errors) rest


checkEmptyFields : List FieldNamePair -> Result (List String) ()
checkEmptyFields fieldsToValidate =
  runValidation
    isEmpty
    []
    fieldsToValidate


validEmail : String -> Bool
validEmail =
  Regex.contains (Regex.regex "^\\S+@\\S+\\.\\S+$")
