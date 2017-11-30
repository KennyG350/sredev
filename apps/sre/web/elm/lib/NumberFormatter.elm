module NumberFormatter exposing (
  abbreviateNumber,
  stripNonNumerics,
  floatToCurrency,
  intToCurrency,
  intToPunctuated)


import String exposing (append, dropRight, right)
import Regex exposing (replace, regex)
import Numeral


type alias Suffix = String


type OrderOfMagnitude
  = Low
  | Thousands
  | Millions
  | Billions


{-| Abbreviate a number with an order of magnitude suffix and possibly 2 decimal places.

    abbreviateNumber 650 == "650"
    abbreviateNumber 20100 == "20K"
    abbreviateNumber 3250000 == "3.25M"
    abbreviateNumber 4000200100 == "4.00B"
-}
abbreviateNumber : Int -> String
abbreviateNumber number =
  case orderOfMagnitude (abs number) of
    Low ->
      toString number

    Thousands ->
      number // 1000
      |> toString
      |> prepend "K"

    Millions ->
      number // 10000
      |> toString
      |> insertDecimalBeforeLastTwo
      |> prepend "M"

    Billions ->
      number // 10000000
      |> toString
      |> insertDecimalBeforeLastTwo
      |> prepend "B"


prepend : Suffix -> String -> String
prepend =
  flip append


{-| Inject a decimal to the left of the last two characters of a string.

    insertDecimalBeforeLastTwo "12345" == "123.45"
-}
insertDecimalBeforeLastTwo : String -> String
insertDecimalBeforeLastTwo string =
  dropRight 2 string
  ++ "."
  ++ right 2 string


{-| Return the order of magnitude of a number (assumed to be positive).

    orderOfMagnitude 250 == Low
    orderOfMagnitude 2500 == Thousands
    orderOfMagnitude 2500000 == Millions
    orderOfMagnitude 2500000000 == Billions
-}
orderOfMagnitude : Int -> OrderOfMagnitude
orderOfMagnitude n =
  if n < 1000 then
    Low

  else if n < 1000000 then
    Thousands

  else if n < 1000000000 then
    Millions

  else
    Billions


stripNonNumerics : String -> String
stripNonNumerics = replace Regex.All (regex "[^\\.\\d-]") (\_ -> "")


floatToCurrency : Float -> String
floatToCurrency = Numeral.format "$0,0"


intToCurrency : Int -> String
intToCurrency = toFloat >> floatToCurrency


floatToPunctuated : Float -> String
floatToPunctuated = Numeral.format "0,0"


intToPunctuated : Int -> String
intToPunctuated = toFloat >> floatToPunctuated
