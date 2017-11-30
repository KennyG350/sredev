module Test.SellCalculator.Calculator exposing (tests)


import Test exposing (Test, test, describe, fuzz2)
import Fuzz exposing (Fuzzer, intRange)
import Expect
import SellCalculator.Calculator as Calculator
import SellCalculator.Types exposing (Price(..), Percent(..), Calculation, priceToString, percentToString, Model)

tests : Test
tests =
  describe "SellCalculator.Calculator"
    [ describe "calculation"
        [ describe "basic use cases" <|
            List.map calculationTest
              [ ( Price 100
                , One
                , { srePercent = Two
                  , sreFee = Price 2
                  , traditionalFee = Price 6
                  , savings = Price 4
                  }
                )
              , ( Price 250000
                , Three
                , { srePercent = Four
                  , sreFee = Price 10000
                  , traditionalFee = Price 15000
                  , savings = Price 5000
                  }
                )
              ]
        , fuzz2 (intRange 0 9000000) (intRange 1 3) "Savings = traditionalFee - sreFee" <|
            \priceInt percentInt ->
              Calculator.calculation (Model (Price <| toFloat priceInt) (percentFromInt percentInt))
              |> \{ savings, traditionalFee, sreFee } -> (savings, traditionalFee, sreFee)
              |> \(Price savings, Price traditionalFee, Price sreFee) -> Expect.equal savings (traditionalFee - sreFee)
        ]
    ]


calculationTest : (Price, Percent, Calculation) -> Test
calculationTest (price, percentToBuyerAgent, expectedResult) =
  test ((priceToString price) ++ " with " ++ (percentToString percentToBuyerAgent)) <|
    \() ->
      Calculator.calculation (Model price percentToBuyerAgent)
      |> Expect.equal expectedResult


percentFromInt : Int -> Percent
percentFromInt int =
  case int of
    1 ->
      One

    2 ->
      Two

    _ ->
      Three
