port module Ports.PubSub exposing (..)


import Json.Encode as JE


type alias Message = String
type alias Payload = JE.Value


-- Send to JS (Cmd)
port broadcast : (Message, Payload) -> Cmd msg
port broadcastWithoutPayload : Message -> Cmd msg


-- Receive from JS (Sub)
port receiveBroadcast : ((Message, Payload) -> msg) -> Sub msg
