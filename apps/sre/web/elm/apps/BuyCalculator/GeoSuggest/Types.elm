module BuyCalculator.GeoSuggest.Types exposing (..)


import Ports.Dom as Dom
import Ports.GooglePlaces as GooglePlaces
import Ports.PubSub as PubSub
import Array exposing (Array)
import Json.Encode as JE


type Msg
  = HandleUserInput (Selector, Dom.HtmlElement, Dom.Event)
  | HandleSubmit (Selector, JE.Value)
  | HandleBlur (Selector, Dom.HtmlElement, Dom.Event)
  | RequestPredictions String
  | ReceivePredictions (List GooglePlaces.AutocompletePrediction)
  | SelectPlace String
  | ClearPredictions
  | HighlightPredictionUp
  | HighlightPredictionDown
  | RequestPlaceDetails String
  | ReceivePlaceDetails GooglePlaces.PlaceResult -- Routes to a search immediately when this happens
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)


type DisplayState
  = Visible
  | Hidden


type alias Model =
  { displayState : DisplayState
  , formSelector : String
  , inputSelector : String
  , predictions : Array GooglePlaces.AutocompletePrediction
  , predictionTypes : List String
  , selectedPrediction : Maybe Int
  }


type alias Flags =
  { formSelector : String
  , inputSelector : String
  }


type alias Selector = String
