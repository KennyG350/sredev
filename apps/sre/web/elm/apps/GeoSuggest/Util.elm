module GeoSuggest.Util exposing (..)


import Regex exposing (HowMany(..), regex)


removeUnitedStatesSuffix : String -> String
removeUnitedStatesSuffix =
  Regex.replace
    All
    (regex ", (United States|USA)")
    (always "")
