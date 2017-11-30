module BuyCalculator.GeoSuggest.App exposing (main)


import Html
import Array
import Ports.GooglePlaces as GooglePlaces
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import BuyCalculator.GeoSuggest.Types exposing (..)
import BuyCalculator.GeoSuggest.Update exposing (update)
import BuyCalculator.GeoSuggest.View exposing (view)


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
  { displayState = Hidden
  , formSelector = flags.formSelector
  , inputSelector = flags.inputSelector
  , predictions = Array.empty
  , predictionTypes = []
  , selectedPrediction = Nothing
  } !
  [ Dom.addEventListener (flags.inputSelector, "keyup", Nothing)
  , Dom.addEventListener (flags.inputSelector, "focus", Nothing)
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
    , GooglePlaces.receiveGooglePlacesDetails ReceivePlaceDetails
    , GooglePlaces.receiveGooglePlacesPredictions ReceivePredictions
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]
