module Filters.PriceRange.Types.PriceLimit exposing (..)


import Maybe exposing (map, map2, withDefault)
import String
import NumberFormatter exposing (stripNonNumerics, intToCurrency)


-- TYPE ALIASES TO HELP REASON ABOUT CODE
type alias SliderOptionIndex = Int
type alias PriceValue = Int


type PriceLimit
  = Limit Int
  | NoLimit


new : Int -> PriceLimit
new n =
  case n > 0 of
    True ->
      Limit n

    False ->
      NoLimit


toMaybe : PriceLimit -> Maybe Int
toMaybe priceLimit =
  case priceLimit of
    Limit n ->
      Just n

    NoLimit ->
      Nothing


fromMaybe : Maybe Int -> PriceLimit
fromMaybe maybe_ =
  case maybe_ of
    Just int ->
      Limit int

    Nothing ->
      NoLimit


fromFloat : Float -> PriceLimit
fromFloat float =
  new (round float)


toFloat : Float -> PriceLimit -> Float
toFloat noLimitValue priceLimit =
  case priceLimit of
    Limit limit ->
      Basics.toFloat limit

    NoLimit ->
      noLimitValue


toString_ : PriceLimit -> String
toString_ =
  toMaybe
  >> (map toString)
  >> (withDefault "")


fromString : String -> PriceLimit
fromString string =
  case String.isEmpty <| stripNonNumerics string of
    True ->
      NoLimit

    False ->
      string
      |> stripNonNumerics
      |> String.toFloat
      |> Result.withDefault 0
      |> round
      |> new


toCurrency : PriceLimit -> Maybe String
toCurrency =
  toMaybe
  >> map intToCurrency


greaterThanOrEqualTo : PriceLimit -> PriceLimit -> Bool
greaterThanOrEqualTo lowPrice highPrice =
  map2 (>=) (toMaybe lowPrice) (toMaybe highPrice)
  |> withDefault False
