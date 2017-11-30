module Monarch.Types exposing (..)


import Dict exposing (Dict)
import Json.Encode
import Navigation exposing (Location)
import Ports.PubSub as PubSub


type alias ElmAppName = String
type alias Selector = String
type alias Flags = Json.Encode.Value
type alias Url = String


type ElmApp
  = Worker ElmAppName
  | WorkerWithFlags ElmAppName Flags
  | Embed ElmAppName Selector
  | EmbedWithFlags ElmAppName Selector Flags


type RouteStrategy
  = NewPageLoadWithUrl Url -- Launch the apps when Monarch initializes if the URL matches the Url regex
  | OnUrl Url -- Launch the apps every time the URL updates matching the Url regex
  | OnBroadcast PubSub.Message -- Launch the apps every time the given Message is broadcast
  | Immediately -- Launch the apps when Monarch initializes


type Msg
  = ReceiveBroadcast (String, Json.Encode.Value)
  | UrlUpdate Location


type alias Route =
  { strategy : RouteStrategy
  , elmApps : List ElmApp
  }


type alias Model =
  { location : Location
  , routesOnUrl : Dict Url (List ElmApp)
  , routesOnBroadcast : Dict PubSub.Message (List ElmApp)
  , newPageLoadWithUrlRoutes : List Url
  }
