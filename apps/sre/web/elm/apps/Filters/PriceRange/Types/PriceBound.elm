module Filters.PriceRange.Types.PriceBound exposing (..)


import Filters.PriceRange.Config exposing (noLimitMessages)
import Filters.RangeSlider.Types.Knob exposing (Knob(..))


type PriceBound
  = Minimum
  | Maximum


toKnob : PriceBound -> Knob
toKnob bound =
  case bound of
    Minimum ->
      LeftKnob

    Maximum ->
      RightKnob


fromKnob : Knob -> PriceBound
fromKnob knob =
  case knob of
    LeftKnob ->
      Minimum

    RightKnob ->
      Maximum


toNoLimitKnobPosition : PriceBound -> Float
toNoLimitKnobPosition bound =
  case bound of
    Minimum ->
      0

    Maximum ->
      1


toNoLimitMessage : PriceBound -> String
toNoLimitMessage bound =
  case bound of
    Minimum ->
      noLimitMessages.minimum

    Maximum ->
      noLimitMessages.maximum


toSelector : PriceBound -> String
toSelector bound =
  case bound of
    Minimum ->
      ".elm-filters-price-minimum"

    Maximum ->
      ".elm-filters-price-maximum"


toHiddenInputSelector : PriceBound -> String
toHiddenInputSelector bound =
  case bound of
    Minimum ->
      ".elm-filters-price-minimum-hidden"

    Maximum ->
      ".elm-filters-price-maximum-hidden"


fromSelector : String -> Maybe PriceBound
fromSelector selector =
  case selector of
    ".elm-filters-price-minimum" ->
      Just Minimum

    ".elm-filters-price-maximum" ->
      Just Maximum

    _ ->
      Nothing
