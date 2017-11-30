module Tests exposing (all)


import Test exposing (concat, Test)


import Test.AppSwitch
import Test.Device
import Test.Filters.PriceRange.Types.PriceLimit
import Test.MapPosition
import Test.Monarch.Update
import Test.NumberFormatter
import Test.Route
import Test.SearchParameters
import Test.SellCalculator.Calculator
import Test.UrlQueryParser


all : Test
all =
  concat
    [ Test.AppSwitch.tests
    , Test.Device.tests
    , Test.Filters.PriceRange.Types.PriceLimit.tests
    , Test.MapPosition.tests
    , Test.Monarch.Update.tests
    , Test.NumberFormatter.tests
    , Test.Route.tests
    , Test.SearchParameters.tests
    , Test.SellCalculator.Calculator.tests
    , Test.UrlQueryParser.tests
    ]
