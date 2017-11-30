module GeoSuggest.App exposing (main)


import Html
import Array
import Json.Encode as JE
import Ports.GooglePlaces as GooglePlaces
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import GeoSuggest.Types exposing (..)
import GeoSuggest.Update exposing (update)
import GeoSuggest.View exposing (view)


main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


init : Flags -> (Model, Cmd Msg)
init flags =
  let
    setValueCmd =
      case flags.defaultValue of
        Just value ->
          [ Dom.setProperty (flags.inputSelector, "value", JE.string value) ]

        Nothing ->
          []
  in
    { displayState = Hidden
    , formSelector = flags.formSelector
    , immediatelySelectMessage = flags.immediatelySelectMessage
    , immediatelySelectNextPrediction = False
    , inputSelector = flags.inputSelector
    , locationSelectedMessage = flags.locationSelectedMessage
    , location = flags.location
    , pathOnPredictionSelected = flags.pathOnPredictionSelected
    , predictions = Array.empty
    , predictionTypes = flags.predictionTypes
    , selectedPrediction = Nothing
    , setBoundsParamOnPredictionSelected = flags.setBoundsParamOnPredictionSelected
    , predictionJustSelected = False
    } !
    List.append
      setValueCmd
      [ Dom.addEventListener (flags.inputSelector, "keyup", Nothing)
      , Dom.addEventListener (flags.inputSelector, "focus", Nothing)
      , Dom.addEventListener (flags.inputSelector, "change", Nothing)
      , Dom.addEventListener (flags.inputSelector, "blur", Nothing)
      , Dom.addSubmitListener (flags.formSelector, [])
      ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onSubmit HandleSubmit
    , Dom.onKeyup HandleUserInput
    , Dom.onFocus HandleUserInput
    , Dom.onBlur HandleBlur
    , Dom.onPaste HandleUserInput
    , Dom.onChange HandleUserInput
    , GooglePlaces.receiveGooglePlacesDetails ReceiveGooglePlacesDetails
    , GooglePlaces.receiveGooglePlacesPredictions ReceivePredictions
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]
