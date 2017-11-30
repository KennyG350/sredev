module Filters.Types.FormSubmission exposing (..)


import Maybe exposing (withDefault)
import Result
import SearchParameters exposing (SearchParameters)


type alias FormSubmission =
  { price_min : String
  , price_max : String
  , property_type_house : Bool
  , property_type_townhouse : Bool
  , property_type_condo : Bool
  , bedrooms : String
  , bathrooms : String
  , home_size_min : String
  , lot_size_min : String
  , year_built_min : String
  }


applyToSearch : SearchParameters -> FormSubmission -> SearchParameters
applyToSearch params submission =
  { params
  | excludeCondo = not submission.property_type_condo
  , excludeHouse = not submission.property_type_house
  , excludeTownhouse = not submission.property_type_townhouse
  , minPrice = String.toInt submission.price_min |> Result.toMaybe
  , maxPrice = String.toInt submission.price_max |> Result.toMaybe
  , minBathrooms = roomsToInt submission.bathrooms
  , minBedrooms = roomsToInt submission.bedrooms
  , minHomeSize = String.toInt submission.home_size_min |> Result.toMaybe
  , minLotSize = String.toFloat submission.lot_size_min |> Result.toMaybe
  , minYearBuilt = String.toInt submission.year_built_min |> Result.toMaybe
  }


fromSearchParameters : SearchParameters -> FormSubmission
fromSearchParameters params =
  { price_min = Maybe.map toString params.minPrice |> withDefault ""
  , price_max = Maybe.map toString params.maxPrice |> withDefault ""
  , property_type_house = not params.excludeHouse
  , property_type_townhouse = not params.excludeTownhouse
  , property_type_condo = not params.excludeCondo
  , bedrooms = roomsToString params.minBedrooms
  , bathrooms = roomsToString params.minBathrooms
  , home_size_min = Maybe.map toString params.minHomeSize |> withDefault ""
  , lot_size_min = Maybe.map lotSizeToString params.minLotSize |> withDefault ""
  , year_built_min = Maybe.map toString params.minYearBuilt |> withDefault ""
  }


roomsToInt : String -> Int
roomsToInt rooms =
  case rooms of
    "1" ->
      1

    "2" ->
      2

    "3" ->
      3

    "4" ->
      4

    "5" ->
      5

    _ ->
      0 -- Corresponds with "any"


roomsToString : Int -> String
roomsToString rooms =
  case rooms of
    1 ->
      "1"

    2 ->
      "2"

    3 ->
      "3"

    4 ->
      "4"

    5 ->
      "5"

    _ ->
      "0" -- Corresponds with "any"


lotSizeToString : Float -> String
lotSizeToString lotSize =
  case lotSize of
    0.5 ->
      "0.5"

    _ ->
      lotSize
      |> round
      |> toString
