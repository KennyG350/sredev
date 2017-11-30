module BuyCalculator.ListingSearch.Types.PriceCategory exposing (..)


import Config


type PriceCategory
  = Under1Million
  | Over1Million


medianFloatToRange : Float -> (Maybe Float, Maybe Float) -- (min, max)
medianFloatToRange median =
  if median == (toFloat lowestSliderOption) then
    (Nothing, Just median)

  else if median == (toFloat highestSliderOption) then
    (Just median, Nothing)

  else
    median
    |> priceCategory
    |> rangePercent
    |> \r ->
         ( Just <| median * (1 - r)
         , Just <| median * (1 + r)
         )


medianIntToRange : Int -> (Maybe Int, Maybe Int) -- (min, max)
medianIntToRange median =
  median
  |> toFloat
  |> medianFloatToRange
  |> \(min, max) ->
       ( Maybe.map round min
       , Maybe.map round max
       )


priceCategory : Float -> PriceCategory
priceCategory price =
  if price < 1000000 then
    Under1Million

  else
    Over1Million


rangePercent : PriceCategory -> Float
rangePercent priceCategory =
  case priceCategory of
    Under1Million ->
      Config.buyCalculatorUnderMillionRangeSpread

    Over1Million ->
      Config.buyCalculatorOverMillionRangeSpread


lowestSliderOption : Int
lowestSliderOption =
  case Config.buySliderOptions of
    lowest :: rest ->
      lowest

    [] ->
      0


highestSliderOption : Int
highestSliderOption =
  case List.reverse Config.buySliderOptions of
    lowest :: rest ->
      lowest

    [] ->
      0
