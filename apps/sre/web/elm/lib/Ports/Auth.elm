port module Ports.Auth exposing (..)


type alias FlashMessageConfig =
  { isError : Bool
  , message : String
  }


-- Send to JS (Cmd)
port showAuth0Modal : Maybe FlashMessageConfig -> Cmd msg


-- Receive from JS (Sub)
port userId : (Maybe Int -> msg) -> Sub msg
