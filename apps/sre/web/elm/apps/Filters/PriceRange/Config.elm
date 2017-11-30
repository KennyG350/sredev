module Filters.PriceRange.Config exposing (..)


import List
import Array exposing (Array, fromList, get, length)


filterResetClickTarget : String
filterResetClickTarget = ".elm-search-properties-toggle-filters"


sliderOptions : Array Int
sliderOptions =
  let
    getMultiples multiplier = List.map (\x -> multiplier * x)
  in
    fromList <|
      getMultiples 10000 (List.range 1 49) -- Multiples of 10k from 10k to 490k
      ++ getMultiples 25000 (List.range 20 39) -- Multiples of 25k from 500k to 975k
      ++ getMultiples 100000 (List.range 10 29) -- Multiples of 100k from 1M to 2.9M
      ++ getMultiples 250000 (List.range 12 20) -- Multiples of 250k from 3M to 5M


totalNotchesInSlider : Int
totalNotchesInSlider = length sliderOptions


-- Display messages when slider knob is at the edge
noLimitMessages : { minimum : String, maximum : String }
noLimitMessages =
  { minimum = "$0", maximum = "$5M+" }
