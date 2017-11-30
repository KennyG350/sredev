port module Ports.Routing exposing (..)


import Navigation


type alias Location = Navigation.Location


-- Send to JS (Cmd)
port broadcastUrlUpdate : Navigation.Location -> Cmd msg


-- Receive from JS (Sub)
port urlUpdate : (Navigation.Location -> msg) -> Sub msg
