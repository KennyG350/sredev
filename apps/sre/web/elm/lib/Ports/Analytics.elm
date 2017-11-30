port module Ports.Analytics exposing (..)


type alias Pathname = String
type alias Title = String


-- Send to JS (Cmd)
port gaPageView : (Pathname, Title) -> Cmd msg
