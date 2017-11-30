module BuyCalculator.GeoSuggest.View exposing (view)


import Array exposing (Array)
import Html exposing (Html, text, ul, li)
import Html.Attributes exposing (class)
import Html.Events exposing (onMouseDown)
import VirtualDom exposing (attribute)
import Ports.GooglePlaces as GooglePlaces
import BuyCalculator.GeoSuggest.Types exposing (..)
import GeoSuggest.Util as Util


view : Model -> Html Msg
view model =
  case model.displayState of
    Visible ->
      renderPredictions model.selectedPrediction model.predictions

    Hidden ->
      text ""


renderPredictions : Maybe Int -> Array GooglePlaces.AutocompletePrediction -> Html Msg
renderPredictions selectedPrediction predictions =
  if Array.isEmpty predictions then
    renderNoResults

  else
    ul [ class "list panel panel--shadow" ]
      <| Array.toList
           <| Array.indexedMap
                (renderPrediction selectedPrediction)
                predictions


renderPrediction : Maybe Int -> Int -> GooglePlaces.AutocompletePrediction -> Html Msg
renderPrediction selectedIndex index prediction =
  let
    liClasses =
      if (Just index == selectedIndex) then
        "list__item onclick list__item--active"

      else
        "list__item onclick"
  in
    li [ class liClasses, attribute "data-place-id" prediction.place_id, onMouseDown (RequestPlaceDetails prediction.place_id) ]
      [ text <| Util.removeUnitedStatesSuffix prediction.description
      ]


renderNoResults : Html Msg
renderNoResults =
  ul [ class "list panel panel--shadow" ]
    [ li [ class "list__item onclick" ]
        [ text "No Results" ]
    ]
