port module Ports.WalkScore exposing (..)


type alias Latitude = String
type alias Longitude = String


-- Commands (Send to JS)
port showWalkScoreTile : (Latitude, Longitude) -> Cmd msg
