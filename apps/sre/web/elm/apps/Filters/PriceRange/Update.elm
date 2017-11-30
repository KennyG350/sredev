module Filters.PriceRange.Update exposing (update)


import List
import Tuple
import Array
import Maybe
import Json.Encode as JE
import Json.Decode as JD
import NumberFormatter exposing (abbreviateNumber)
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Filters.PriceRange.Types exposing (..)
import Filters.PriceRange.Types.PriceLimit as PriceLimit exposing (PriceLimit(..))
import Filters.PriceRange.Types.PriceBound as PriceBound exposing (PriceBound(..))
import Filters.PriceRange.Config exposing (sliderOptions, totalNotchesInSlider)
import Filters.RangeSlider.Types.Knob exposing (Knob(..), KnobPositionUpdate, encodeKnobPositionUpdate, decodeKnobPositionUpdate)


type alias PriceValue = Int
type alias SliderOptionIndex = Int
type alias SetPriceRangePayload = { minimum : String, maximum : String }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ResetPriceRange ->
      let
        model_ = Model NoLimit NoLimit
      in
        model_ !
        [ updateSliderCmd model_
        , updateInputsCmd model_
        , updateTooltipCmd model_
        ]

    OnBlur (selector, { value }, _) ->
      case PriceBound.fromSelector selector of
        Just bound ->
          let
            newValue =
              value
              |> Maybe.withDefault ""
              |> NumberFormatter.stripNonNumerics
              |> String.toFloat
              |> Result.withDefault 0
              |> PriceLimit.fromFloat

            minimum = if bound == Minimum then newValue else model.minimum
            maximum = if bound == Maximum then newValue else model.maximum
            boundsCrossed = PriceLimit.greaterThanOrEqualTo minimum maximum

            model_ =
              case (boundsCrossed, bound) of
                (False, _) ->
                  { model | minimum = minimum, maximum = maximum }

                (True, Minimum) ->
                  { model | minimum = minimum, maximum = NoLimit }

                (True, Maximum) ->
                  { model | minimum = NoLimit, maximum = maximum }
          in
            model_ !
            [ updateInputsCmd model_
            , updateSliderCmd model_
            , updateTooltipCmd model_
            ]

        _ ->
          model ! []

    OnFocus (selector, { value }, _) ->
      case (PriceBound.fromSelector selector, value) of
        (Just bound, Just value_) ->
          let
            newValue =
              if (limitFromBound model bound) == NoLimit then
                ""

              else
                NumberFormatter.stripNonNumerics value_
          in
            ( model
            , Dom.setProperty (selector, "value", JE.string newValue)
            )

        _ ->
          model ! []

    ReceiveBroadcast ("knobPositionUpdated", payload) ->
      case decodeKnobPositionUpdate payload of
        Ok { knob, position } ->
          let
            bound = PriceBound.fromKnob knob
            limit = knobPositionToPriceLimit position
            minimum = if bound == Minimum then limit else model.minimum
            maximum = if bound == Maximum then limit else model.maximum
            model_ = { model | minimum = minimum, maximum = maximum }
          in
            model_ !
            [ updateInputsCmd model_
            , updateTooltipCmd model_
            ]

        Err _ ->
          model ! []

    ReceiveBroadcast ("setPriceRange", payload) ->
      case JD.decodeValue setPriceRangeDecoder payload of
        Ok { minimum, maximum } ->
          let
            min = PriceLimit.fromString minimum
            max = PriceLimit.fromString maximum
            boundsCrossed = PriceLimit.greaterThanOrEqualTo min max

            model_ =
              if boundsCrossed then
                { model | minimum = min, maximum = NoLimit }

              else
                { model | minimum = min, maximum = max }
          in
            model_ !
            [ updateInputsCmd model_
            , updateSliderCmd model_
            , updateTooltipCmd model_
            ]

        Err _ ->
          model ! []

    _ ->
      model ! []


limitFromBound : Model -> PriceBound -> PriceLimit
limitFromBound { minimum, maximum } bound =
  case bound of
    Minimum ->
      minimum

    Maximum ->
      maximum


updateInputsCmd : Model -> Cmd Msg
updateInputsCmd { minimum, maximum } =
  Cmd.batch
    [ Dom.setProperty
        ( PriceBound.toSelector Minimum
        , "value"
        , JE.string <|
            toCurrencyWithNoLimitDefault Minimum minimum
        )
    , Dom.setProperty
        ( PriceBound.toSelector Maximum
        , "value"
        , JE.string <|
            toCurrencyWithNoLimitDefault Maximum maximum
        )
    , Dom.setProperty
        ( PriceBound.toHiddenInputSelector Minimum
        , "value"
        , JE.string <| PriceLimit.toString_ minimum
        )
    , Dom.setProperty
        ( PriceBound.toHiddenInputSelector Maximum
        , "value"
        , JE.string <| PriceLimit.toString_ maximum
        )
    ]


updateSliderCmd : Model -> Cmd Msg
updateSliderCmd { minimum, maximum } =
  Cmd.batch
    [ PubSub.broadcast ("updateKnobPosition", knobPositionUpdate Minimum minimum)
    , PubSub.broadcast ("updateKnobPosition", knobPositionUpdate Maximum maximum)
    ]


updateTooltipCmd : Model -> Cmd Msg
updateTooltipCmd { minimum, maximum } =
  [ toAbbreviatedCurrency Minimum minimum
  , "-"
  , toAbbreviatedCurrency Maximum maximum
  ]
  |> String.join " "
  |> \tooltip -> Dom.innerHtml (".elm-range-slider-tooltip", tooltip)


knobPositionUpdate : PriceBound -> PriceLimit -> JE.Value
knobPositionUpdate bound limit =
  limit
  |> knobPositionFromPriceLimit (PriceBound.toNoLimitKnobPosition bound)
  |> KnobPositionUpdate (PriceBound.toKnob bound)
  |> encodeKnobPositionUpdate


toCurrencyWithNoLimitDefault : PriceBound -> PriceLimit -> String
toCurrencyWithNoLimitDefault bound limit =
  Maybe.withDefault
    (PriceBound.toNoLimitMessage bound)
    (PriceLimit.toCurrency limit)


toAbbreviatedCurrency : PriceBound -> PriceLimit -> String
toAbbreviatedCurrency bound priceLimit =
  case priceLimit of
    Limit price ->
      "$" ++ abbreviateNumber price

    NoLimit ->
      PriceBound.toNoLimitMessage bound


knobPositionFromPriceLimit : Float -> PriceLimit -> Float -- Return the closest "snap option's" knob position (round down)
knobPositionFromPriceLimit noLimitPosition priceLimit =
  case priceLimit of
    Limit price ->
      toFloat (Tuple.first <| getHighestSliderOptionBelow price)
      / (toFloat totalNotchesInSlider)

    NoLimit ->
      noLimitPosition


knobPositionToPriceLimit : Float -> PriceLimit
knobPositionToPriceLimit position =
  case position of
    0 ->
      NoLimit

    1 ->
      NoLimit

    _ ->
      PriceLimit.fromMaybe <|
        Array.get
          (floor <| toFloat totalNotchesInSlider * position)
          sliderOptions


getHighestSliderOptionBelow : PriceValue -> (SliderOptionIndex, PriceValue)
getHighestSliderOptionBelow price =
  let
    reducer = \(index, currentPrice) previousOption ->
      case currentPrice <= price of
        True ->
          (index, currentPrice)

        False ->
          previousOption
  in
    List.foldl reducer (0, 0) <| Array.toIndexedList sliderOptions


setPriceRangeDecoder : JD.Decoder SetPriceRangePayload
setPriceRangeDecoder =
  JD.map2 SetPriceRangePayload
    (JD.field "minimum" JD.string)
    (JD.field "maximum" JD.string)
