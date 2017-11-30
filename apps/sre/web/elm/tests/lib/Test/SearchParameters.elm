module Test.SearchParameters exposing (tests)


import Test exposing (Test, describe, test)
import Expect
import SearchParameters exposing (SearchParameters, SortOption(..))
import Ports.GoogleMaps as GoogleMaps


tests : Test
tests =
  describe "SearchParameters"
    [ describe "toJson >> fromJson yields the original SearchParameters record" <|
        List.map serializeTest sampleSearchParameters
    , describe "toQueryParams produces the expected query string" <|
        List.map toQueryParamsTest sampleSearchParametersAndQueries
    , describe "fromQueryParams produces the expected SearchParameters" <|
        List.map fromQueryParamsTest sampleSearchParametersAndQueries
    ]


serializeTest : SearchParameters -> Test
serializeTest params =
  test (SearchParameters.toQueryParams params) <|
    \() ->
      params
      |> SearchParameters.toJson
      |> SearchParameters.fromJson
      |> Expect.equal params


toQueryParamsTest : { params : SearchParameters, queryString : String } -> Test
toQueryParamsTest { params, queryString } =
  test queryString <|
    \() ->
      params
      |> SearchParameters.toQueryParams
      |> Expect.equal queryString


fromQueryParamsTest : { params : SearchParameters, queryString : String } -> Test
fromQueryParamsTest { params, queryString } =
  test queryString <|
    \() ->
      queryString
      |> SearchParameters.fromQueryParams
      |> Expect.equal params


sampleSearchParameters : List SearchParameters
sampleSearchParameters =
  List.map .params sampleSearchParametersAndQueries


sampleSearchParametersAndQueries : List { params : SearchParameters, queryString : String }
sampleSearchParametersAndQueries =
  [ { params =
        { bounds = Just ({lat = 123.45, lng = 33.456}, {lat = 124.56, lng = 34.567})
        , excludeCondo = False
        , excludeHouse = True
        , excludeTownhouse = False
        , location = Just "Phoenix, AZ"
        , minPrice = Just 500000
        , maxPrice = Just 690000
        , minBathrooms = 3
        , minBedrooms = 5
        , minHomeSize = Just 1800
        , minLotSize = Nothing
        , minYearBuilt = Nothing
        , page = 4
        , sort = HighestPrice
        }
    , queryString =
        "?location=Phoenix, AZ&bounds=123.45,33.456,124.56,34.567&page=4&price_min=500000"
        ++ "&price_max=690000&bathrooms=3&bedrooms=5&home_size_min=1800"
        ++ "&exclude_house=true&sort=highest_price"
    }
  , { params =
        { bounds = Just ({lat = 123.45, lng = 33.456}, {lat = 124.56, lng = 34.567})
        , excludeCondo = True
        , excludeHouse = True
        , excludeTownhouse = True
        , location = Nothing
        , minPrice = Just 2600000
        , maxPrice = Just 10000000
        , minBathrooms = 7
        , minBedrooms = 13
        , minHomeSize = Just 28000
        , minLotSize = Just 3.0
        , minYearBuilt = Just 1995
        , page = 1
        , sort = LowestPrice
        }
    , queryString =
        "?bounds=123.45,33.456,124.56,34.567&price_min=2600000"
        ++ "&price_max=10000000&bathrooms=7&bedrooms=13&home_size_min=28000"
        ++ "&lot_size_min=3&year_built_min=1995&exclude_condo=true&exclude_house=true"
        ++ "&exclude_townhouse=true&sort=lowest_price"
    }
  , { params = SearchParameters.empty
    , queryString = "?"
    }
  , { params =
        { bounds = Just ({lat = 21.2548377, lng = -157.949443}, {lat = 21.4012299, lng = -157.6487031})
        , excludeCondo = False
        , excludeHouse = False
        , excludeTownhouse = True
        , location = Nothing
        , minPrice = Nothing
        , maxPrice = Just 150000
        , minBathrooms = 2
        , minBedrooms = 3
        , minHomeSize = Nothing
        , minLotSize = Nothing
        , minYearBuilt = Nothing
        , page = 1
        , sort = LowestPrice
        }
    , queryString =
        "?bounds=21.2548377,-157.949443,21.4012299,-157.6487031&price_max=150000"
        ++ "&bathrooms=2&bedrooms=3&exclude_townhouse=true&sort=lowest_price"
    }
  ]
