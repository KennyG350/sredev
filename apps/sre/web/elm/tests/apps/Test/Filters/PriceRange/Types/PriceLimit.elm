module Test.Filters.PriceRange.Types.PriceLimit exposing (tests)


import String
import List
import Expect
import Test exposing (Test, test, fuzz, describe)
import Filters.PriceRange.Types.PriceLimit as PriceLimit exposing (PriceLimit(..))
import Fuzz exposing (int, intRange)


tests : Test
tests =
  describe "Filters.PriceLimit"
    [ describe "toString_"
        [ test "NoLimit" <|
            \() ->
              PriceLimit.toString_ NoLimit
              |> String.isEmpty
              |> Expect.true "Expected NoLimit to yield an empty string"
        , fuzz int "Limit Int yields a string version of the int" <|
            \anInt ->
              PriceLimit.toString_ (Limit anInt)
              |> Expect.equal (toString anInt)
        ]
    , describe "fromString" <|
        List.map fromStringTest
          [ ("100", Limit 100)
          , ("500.5", Limit 501)
          , ("100.1", Limit 100)
          , ("-1", NoLimit)
          , ("asdf", NoLimit)
          ]
    , describe "toCurrency"
        [ test "NoLimit" <|
            \() ->
              NoLimit
              |> PriceLimit.toCurrency
              |> Expect.equal Nothing
        , test "Small number" <|
            \() ->
              Limit 100
              |> PriceLimit.toCurrency
              |> Expect.equal (Just "$100")
        , test "Large number" <|
            \() ->
              Limit 950500300000
              |> PriceLimit.toCurrency
              |> Expect.equal (Just "$950,500,300,000")
        ]
    , describe "greaterThanOrEqualTo"
        [ test "NoLimit for both operands" <|
            \() ->
              PriceLimit.greaterThanOrEqualTo NoLimit NoLimit
              |> Expect.false "should yield False"
        , fuzz (intRange 1 10000000) "NoLimit for first operand" <|
            \anInt ->
              PriceLimit.greaterThanOrEqualTo NoLimit (Limit anInt)
              |> Expect.false "should yield False"
        , fuzz (intRange 1 10000000) "NoLimit for second operand" <|
            \anInt ->
              PriceLimit.greaterThanOrEqualTo (Limit anInt) NoLimit
              |> Expect.false "should yield False"
        , test "Limit 50000 >= Limit 10" <|
            \() ->
              PriceLimit.greaterThanOrEqualTo (Limit 50000) (Limit 10)
              |> Expect.true "should be true"
        , fuzz (intRange 1 10000000) "Same Limits" <|
            \anInt ->
              PriceLimit.greaterThanOrEqualTo (Limit anInt) (Limit anInt)
              |> Expect.true "should be true (greater than or EQUAL TO)"
        ]
    ]


fromStringTest : (String, PriceLimit) -> Test
fromStringTest (aString, expectedResult) =
  test aString <|
    \() ->
      PriceLimit.fromString aString |> Expect.equal expectedResult
