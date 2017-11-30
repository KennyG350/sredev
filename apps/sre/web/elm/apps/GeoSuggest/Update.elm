module GeoSuggest.Update exposing (update)


import UrlQueryParser
import Array exposing (Array)
import String
import List
import RouteHelper
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Ports.GooglePlaces as GooglePlaces
import SearchParameters
import GeoSuggest.Types exposing (..)
import GeoSuggest.Util as Util
import Json.Encode as JE
import Json.Decode as JD


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HandleUserInput (selector, { value }, { keyCode }) ->
      if model.predictionJustSelected then
        { model | predictionJustSelected = False } ! []

      else
        case (keyCode, value, selector == model.inputSelector) of
          (Just 38, _, True) -> -- Up arrow
            update HighlightPredictionUp model

          (Just 40, _, True) -> -- Down arrow
            update HighlightPredictionDown model

          (Just 13, _, True) -> -- Enter
            case getAutocompletePrediction model.selectedPrediction model.predictions of
              Just { place_id } ->
                update (GetPlaceDetailsForNewSearch place_id) model

              Nothing ->
                model ! []

          (_, Just value_, True) ->
            if (String.length value_) < 3 then
              update ClearPredictions model

            else
              update (RequestPredictions value_) model

          _ ->
            model ! []

    HandleSubmit (selector, _) ->
      if selector == model.formSelector then
        handleSubmit model

      else
        model ! []

    HandleBlur _ ->
      { model | displayState = Hidden } ! []

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
      if model.immediatelySelectNextPrediction then
        case predictions of
          [] ->
            model ! []

          { place_id } :: remainingPredictions ->
            update
              (GetPlaceDetailsForNewSearch place_id)
              { model
              | predictions = Array.fromList predictions
              , displayState = Hidden
              , immediatelySelectNextPrediction = False
              }

      else
        { model
        | predictions = Array.fromList predictions
        , displayState = Visible
        } ! []

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

    GetPlaceDetailsForNewSearch placeId ->
      model !
      [ GooglePlaces.requestGooglePlacesDetails placeId
      ]

    ReceiveGooglePlacesDetails place ->
      let
        { formatted_address, bounds } = place
        { location } = model
        name = Util.removeUnitedStatesSuffix formatted_address
        (model_, _) = update ClearPredictions model

        queryParams =
          case model.setBoundsParamOnPredictionSelected of
            True ->
              ""
                |> UrlQueryParser.setQueryParam "location" name
                |> UrlQueryParser.setQueryParam "bounds" bounds
                |> String.dropLeft 1
                |> String.append "?"

            False ->
              ""
                |> UrlQueryParser.setQueryParam "location" name
                |> String.dropLeft 1
                |> String.append "?"

        historyCmds =
          case model.pathOnPredictionSelected of
            Just path_ ->
              [ RouteHelper.newUrl (path_ ++ queryParams)
              , RouteHelper.reload
              ]

            Nothing ->
              []
      in
        { model_ | predictionJustSelected = True } !
        List.append
          historyCmds
          [ Dom.setProperty (model.inputSelector, "value", JE.string name)
          , PubSub.broadcast (model.locationSelectedMessage, GooglePlaces.encodePlaceResult place)
          ]

    UrlUpdate location ->
      { model | location = location } ! []

    ReceiveBroadcast ("performNewCardsSearch", searchParameters) ->
      -- Update display value on forward/back
      case .location <| SearchParameters.fromJson searchParameters of
        Just location ->
          ( model
          , Dom.setProperty (model.inputSelector, "value", JE.string location)
          )

        Nothing ->
          model ! []

    ReceiveBroadcast (message, payload) ->
      case (model.immediatelySelectMessage, JD.decodeValue JD.string payload) of
        (Just immediatelySelectMessage, Ok searchQuery) ->
          if message == immediatelySelectMessage then
            update
              (RequestPredictions searchQuery)
              { model | immediatelySelectNextPrediction = True }

          else
            model ! []

        _ ->
          model ! []


handleSubmit : Model -> (Model, Cmd Msg)
handleSubmit model =
  let
    selectedPrediction = getAutocompletePrediction model.selectedPrediction model.predictions
    predictionsEmpty = Array.isEmpty model.predictions
  in
    case (selectedPrediction, predictionsEmpty) of
      (Just prediction, False) -> -- Prediction is selected (via keyboard); click on it
        update (GetPlaceDetailsForNewSearch prediction.place_id) model

      (Nothing, False) -> -- No prediction selected, user hit "enter" while focused on the input; Click on the first prediction
        case Array.get 0 model.predictions of
          Just prediction ->
            update (GetPlaceDetailsForNewSearch prediction.place_id) model

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
