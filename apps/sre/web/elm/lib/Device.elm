module Device exposing (..)


import String


type Device
  = Desktop
  | Mobile


fromString : String -> Device
fromString s =
  case String.toLower s of
    "mobile" ->
      Mobile

    "desktop" ->
      Desktop

    _ -> -- Default to desktop
      Desktop
