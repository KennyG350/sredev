module GeoSuggest.Types exposing (..)


import Ports.Dom as Dom
import Ports.GooglePlaces as GooglePlaces
import Ports.Routing as Routing
import Ports.PubSub as PubSub
import Array exposing (Array)
import Json.Encode as JE


type Msg
  = HandleUserInput (Selector, Dom.HtmlElement, Dom.Event)
  | HandleSubmit (Selector, JE.Value)
  | HandleBlur (Selector, Dom.HtmlElement, Dom.Event)
  | RequestPredictions String
  | ReceivePredictions (List GooglePlaces.AutocompletePrediction)
  | ClearPredictions
  | HighlightPredictionUp
  | HighlightPredictionDown
  | GetPlaceDetailsForNewSearch String
  | ReceiveGooglePlacesDetails GooglePlaces.PlaceResult
  | UrlUpdate Routing.Location
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)


type DisplayState
  = Visible
  | Hidden


type alias Model =
  { displayState : DisplayState
  , formSelector : String
  , inputSelector : String
  , locationSelectedMessage : String
  , immediatelySelectMessage : Maybe String
  , immediatelySelectNextPrediction : Bool
  , location : Routing.Location
  , pathOnPredictionSelected : Maybe String
  , predictions : Array GooglePlaces.AutocompletePrediction
  , predictionTypes : List String
  , selectedPrediction : Maybe Int
  , setBoundsParamOnPredictionSelected : Bool
  , predictionJustSelected : Bool
  }


type alias Flags =
  { defaultValue : Maybe String
  , formSelector : String
  , inputSelector : String

  -- PubSub message to broadcast when a location is selected
  , locationSelectedMessage : String

  -- PubSub message which, when received, will immediately select the first match of the given query
  , immediatelySelectMessage : Maybe String

  -- Passed directly to Google Places API
  , predictionTypes : List String

  -- Where to go (e.g. "/properties") when prediction selected
  , pathOnPredictionSelected : Maybe String

  -- Whether to set `&bounds=...` when prediction selected
  , setBoundsParamOnPredictionSelected : Bool
  , location : Routing.Location
  }


type alias Selector = String
