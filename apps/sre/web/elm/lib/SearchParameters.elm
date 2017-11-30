module SearchParameters exposing
  ( SearchParameters
  , SortOption(..)
  , toJson
  , fromJson
  , toQueryParams
  , fromQueryParams
  , updateSortOption
  , sortOptionToString
  , empty)


import Maybe exposing (withDefault)
import Result
import Json.Encode as JE
import Json.Decode as JD
import Maybe.Extra as ME
import UrlQueryParser
import Ports.GoogleMaps as GoogleMaps exposing (LatLngBounds)


type alias SearchParameters =
  { bounds : Maybe LatLngBounds
  , excludeCondo : Bool
  , excludeHouse : Bool
  , excludeTownhouse : Bool
  , location : Maybe String
  , minPrice : Maybe Int
  , maxPrice : Maybe Int
  , minBathrooms : Int
  , minBedrooms : Int
  , minHomeSize : Maybe Int
  , minLotSize : Maybe Float
  , minYearBuilt : Maybe Int
  , page : Int
  , sort : SortOption
  }


type SortOption
  = RecentlyAdded
  | HighestPrice
  | LowestPrice


sortOptionToString : SortOption -> String
sortOptionToString sortOption =
  case sortOption of
    RecentlyAdded ->
      "recent"

    HighestPrice ->
      "highest_price"

    LowestPrice ->
      "lowest_price"


sortOptionFromString : String -> SortOption
sortOptionFromString s =
  case s of
    "recent" ->
      RecentlyAdded

    "highest_price" ->
      HighestPrice

    "lowest_price" ->
      LowestPrice

    _ ->
      defaultSortOption


defaultSortOption : SortOption
defaultSortOption = RecentlyAdded


toJson : SearchParameters -> JE.Value
toJson params =
  JE.object
    [ ("page", JE.int params.page)
    , ("sort", JE.string <| sortOptionToString params.sort)
    , ("minBathrooms", JE.int params.minBathrooms)
    , ("minBedrooms", JE.int params.minBedrooms)
    , ( "bounds"
      , case params.bounds of
          Just (southwest, northeast) ->
            JE.list
              [ GoogleMaps.latLngToJson southwest
              , GoogleMaps.latLngToJson northeast
              ]

          Nothing ->
            JE.null
      )
    , ("excludeCondo", JE.bool params.excludeCondo)
    , ("excludeHouse", JE.bool params.excludeHouse)
    , ("excludeTownhouse", JE.bool params.excludeTownhouse)
    , ( "location"
      , params.location |> Maybe.map JE.string |> withDefault JE.null
      )
    , ( "minHomeSize"
      , params.minHomeSize |> Maybe.map JE.int |> withDefault JE.null
      )
    , ( "minLotSize"
      , params.minLotSize |> Maybe.map JE.float |> withDefault JE.null
      )
    , ( "minPrice"
      , params.minPrice |> Maybe.map JE.int |> withDefault JE.null
      )
    , ( "maxPrice"
      , params.maxPrice |> Maybe.map JE.int |> withDefault JE.null
      )
    , ( "minYearBuilt"
      , params.minYearBuilt |> Maybe.map JE.int |> withDefault JE.null
      )
    ]


fromJson : JD.Value -> SearchParameters
fromJson jsonValue =
  let
    decodeWithDefault = \fieldName decoder default -> JD.decodeValue (JD.field fieldName decoder) jsonValue |> Result.withDefault default
    decodeToMaybe = \fieldName decoder -> JD.decodeValue (JD.field fieldName decoder) jsonValue |> Result.toMaybe
  in
    { page = decodeWithDefault "page" JD.int 1
    , sort = sortOptionFromString (decodeWithDefault "sort" JD.string "")
    , minBathrooms = decodeWithDefault "minBathrooms" JD.int 0
    , minBedrooms = decodeWithDefault "minBedrooms" JD.int 0
    , bounds = decodeToMaybe "bounds" GoogleMaps.latLngBoundsDecoder
    , excludeCondo = decodeWithDefault "excludeCondo" JD.bool False
    , excludeHouse = decodeWithDefault "excludeHouse" JD.bool False
    , excludeTownhouse = decodeWithDefault "excludeTownhouse" JD.bool False
    , location = decodeToMaybe "location" JD.string
    , minHomeSize = decodeToMaybe "minHomeSize" JD.int
    , minLotSize = decodeToMaybe "minLotSize" JD.float
    , minPrice = decodeToMaybe "minPrice" JD.int
    , maxPrice = decodeToMaybe "maxPrice" JD.int
    , minYearBuilt = decodeToMaybe "minYearBuilt" JD.int
    }


toQueryParams : SearchParameters -> String
toQueryParams search =
  [ Maybe.map (String.append "location=") search.location
  , Maybe.map boundsQueryString search.bounds
  , pageQueryString search.page
  , Maybe.map (intQueryString "price_min") search.minPrice
  , Maybe.map (intQueryString "price_max") search.maxPrice
  , roomString "bathrooms" search.minBathrooms
  , roomString "bedrooms" search.minBedrooms
  , Maybe.map (intQueryString "home_size_min") search.minHomeSize
  , Maybe.map lotSizeString search.minLotSize
  , Maybe.map (intQueryString "year_built_min") search.minYearBuilt
  , boolQueryString "exclude_condo" search.excludeCondo
  , boolQueryString "exclude_house" search.excludeHouse
  , boolQueryString "exclude_townhouse" search.excludeTownhouse
  , sortOptionQueryString search.sort
  ]
  |> List.filter ME.isJust
  |> ME.combine
  |> withDefault []
  |> String.join "&"
  |> String.append "?"


fromQueryParams : String -> SearchParameters
fromQueryParams search =
  let
    get = UrlQueryParser.getQueryParam search

    paramToInt =
      (Maybe.map String.toInt)
      >> (Maybe.map Result.toMaybe)
      >> (ME.join)

    paramToFloat =
      (Maybe.map String.toFloat)
      >> (Maybe.map Result.toMaybe)
      >> (ME.join)

    toIntWithDefault = \default maybeString -> paramToInt maybeString |> withDefault default
  in
    { page = get "page" |> toIntWithDefault 1
    , sort = get "sort" |> withDefault "" |> sortOptionFromString
    , minBathrooms = get "bathrooms" |> toIntWithDefault 0
    , minBedrooms = get "bedrooms" |> toIntWithDefault 0
    , bounds =
        get "bounds"
        |> Maybe.map GoogleMaps.latLngBoundsFromString
        |> ME.join
    , excludeCondo = (get "exclude_condo") == (Just "true")
    , excludeHouse = (get "exclude_house") == (Just "true")
    , excludeTownhouse = (get "exclude_townhouse") == (Just "true")
    , location = get "location"
    , minHomeSize = get "home_size_min" |> paramToInt
    , minLotSize = get "lot_size_min" |> paramToFloat
    , minPrice = get "price_min" |> paramToInt
    , maxPrice = get "price_max" |> paramToInt
    , minYearBuilt = get "year_built_min" |> paramToInt
    }


boundsQueryString : LatLngBounds -> String
boundsQueryString bounds =
  "bounds=" ++ (GoogleMaps.latLngBoundsToString bounds)


pageQueryString : Int -> Maybe String
pageQueryString page =
  if page == 1 then
    Nothing

  else
    Just <| intQueryString "page" page


{-| For rooms, 0 means remove it from the query string
-}
roomString : String -> Int -> Maybe String
roomString paramName rooms =
  if rooms == 0 then
    Nothing

  else
    Just <| intQueryString paramName rooms


intQueryString : String -> Int -> String
intQueryString paramName int =
  paramName ++ "=" ++ (toString int)


{-| Lot size is measured in acres.
-}
lotSizeString : Float -> String
lotSizeString lotSize =
  String.append "lot_size_min=" <|
    case lotSize of
      0.5 ->
        "0.5"

      _ ->
        lotSize
        |> round
        |> toString


boolQueryString : String -> Bool -> Maybe String
boolQueryString paramName bool =
  if bool then
    Just (paramName ++ "=true")

  else
    Nothing


sortOptionQueryString : SortOption -> Maybe String
sortOptionQueryString sortOption =
  if sortOption == defaultSortOption then
    Nothing

  else
    Just ("sort=" ++ (sortOptionToString sortOption))


updateSortOption : String -> SearchParameters -> SearchParameters
updateSortOption sortString params =
  { params | sort = sortOptionFromString sortString }


empty : SearchParameters
empty =
  { page = 1
  , sort = defaultSortOption
  , minBathrooms = 0
  , minBedrooms = 0
  , bounds = Nothing
  , excludeCondo = False
  , excludeHouse = False
  , excludeTownhouse = False
  , location = Nothing
  , minHomeSize = Nothing
  , minLotSize = Nothing
  , minPrice = Nothing
  , maxPrice = Nothing
  , minYearBuilt = Nothing
  }
