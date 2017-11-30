module BuyCalculator.GeoSuggest.Update exposing (update)


import Array exposing (Array)
import String
import RouteHelper
import Ports.Dom as Dom
import Ports.GooglePlaces as GooglePlaces
import BuyCalculator.GeoSuggest.Types exposing (..)
import GeoSuggest.Util as Util
import Json.Encode as JE
import Json.Decode as JD


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HandleUserInput (selector, { value }, { keyCode }) ->
      case (keyCode, value, selector == model.inputSelector) of
        (Just 38, _, True) -> -- Up arrow
          update HighlightPredictionUp model

        (Just 40, _, True) -> -- Down arrow
          update HighlightPredictionDown model

        (Just 13, _, True) -> -- Enter; submit form and go to search results
          case getAutocompletePrediction model.selectedPrediction model.predictions of
            Just { place_id } ->
              update (RequestPlaceDetails place_id) model

            Nothing ->
              model ! []

        (_, Just value_, True) ->
          if (String.length value_) < 3 then
            update ClearPredictions model

          else
            update (RequestPredictions value_) model

        _ ->
          model ! []

    ReceiveBroadcast (message, payload) ->
      case (message, JD.decodeValue JD.string payload) of
        ("feedMapPinClicked", Ok searchQuery) ->
          ( model
          , Dom.setProperty (model.inputSelector, "value", JE.string searchQuery)
          )

        _ ->
          model ! []

    RequestPredictions searchQuery ->
      { model
      | selectedPrediction = Nothing
      } !
      [ GooglePlaces.requestGooglePlacesPredictions
          ( searchQuery
          , model.predictionTypes
          , GooglePlaces.ComponentRestrictions "us"
          )
      ]

    ReceivePredictions predictions ->
      { model
      | predictions = Array.fromList predictions
      , displayState = Visible
      } ! []

    SelectPlace placeDescription ->
      ( model
      , Dom.setProperty (model.inputSelector, "value", JE.string placeDescription)
      )

    ClearPredictions ->
      { model
      | displayState = Hidden
      , predictions = Array.empty
      , selectedPrediction = Nothing
      } ! []

    HighlightPredictionUp ->
      case (Array.isEmpty model.predictions, model.selectedPrediction) of
        (True, _) ->
          model ! []

        (False, Nothing) ->
          { model
          | selectedPrediction = Just (lastIndex model.predictions)
          } ! []

        (False, Just index) ->
          let
            new_index =
              if index == 0 then
                lastIndex model.predictions

              else
                index - 1
          in
            { model
            | selectedPrediction = Just new_index
            } ! []

    HighlightPredictionDown ->
      case (Array.isEmpty model.predictions, model.selectedPrediction) of
        (True, _) ->
          model ! []

        (False, Nothing) ->
          { model
          | selectedPrediction = Just 0
          } ! []

        (False, Just index) ->
          let
            new_index =
              if index == (lastIndex model.predictions) then
                0

              else
                index + 1
          in
            { model
            | selectedPrediction = Just new_index
            } ! []

    HandleBlur _ ->
      { model | displayState = Hidden } ! []

    HandleSubmit (selector, _) ->
      if selector == model.formSelector then
        handleSubmit model

      else
        model ! []

    RequestPlaceDetails placeId ->
      model !
      [ GooglePlaces.requestGooglePlacesDetails placeId
      ]

    ReceivePlaceDetails { formatted_address, bounds } ->
      let
        location = Util.removeUnitedStatesSuffix formatted_address
      in
        model !
        [ Dom.setProperty (model.inputSelector, "value", JE.string location)
        , RouteHelper.newUrl ("/properties?location=" ++ location ++ "&bounds=" ++ bounds)
        , RouteHelper.reload
        ]


handleSubmit : Model -> (Model, Cmd Msg)
handleSubmit model =
  let
    selectedPrediction = getAutocompletePrediction model.selectedPrediction model.predictions
    predictionsEmpty = Array.isEmpty model.predictions
  in
    case (selectedPrediction, predictionsEmpty) of
      (Just prediction, False) -> -- Prediction is selected (via keyboard); click on it
        update (RequestPlaceDetails prediction.place_id) model

      (Nothing, False) -> -- No prediction selected, user hit "enter" while focused on the input; Click on the first prediction
        case Array.get 0 model.predictions of
          Just prediction ->
            update (RequestPlaceDetails prediction.place_id) model

          Nothing ->
            model ! []

      (Nothing, True) -> -- User hit enter but there are no predictions, so focus on the input
        model ! [ Dom.focus model.inputSelector ]

      _ ->
        model ! []


getAutocompletePrediction : Maybe Int -> Array GooglePlaces.AutocompletePrediction -> Maybe GooglePlaces.AutocompletePrediction
getAutocompletePrediction index predictions =
  case index of
    Just index_ ->
      Array.get index_ predictions

    Nothing ->
      Nothing


lastIndex : Array a -> Int
lastIndex array =
  (Array.length array) - 1
