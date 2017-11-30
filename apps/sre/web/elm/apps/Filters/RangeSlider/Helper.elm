module Filters.RangeSlider.Helper exposing (..)


import Filters.RangeSlider.Types.Knob exposing (Knob(..))


leftKnobSelector : String -> String
leftKnobSelector sliderSelector =
  sliderSelector ++ " .elm-range-slider-knob-left"


rightKnobSelector : String -> String
rightKnobSelector sliderSelector =
  sliderSelector ++ " .elm-range-slider-knob-right"


knobToSelector : String -> Knob -> String
knobToSelector sliderSelector knob =
  case knob of
    LeftKnob ->
      leftKnobSelector sliderSelector

    RightKnob ->
      rightKnobSelector sliderSelector
