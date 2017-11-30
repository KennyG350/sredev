module Test.NumberFormatter exposing (tests)


import Test exposing (..)
import Expect
import NumberFormatter


tests : Test
tests =
  describe "NumberFormatter"
    [ describe "abbreviateNumber" <|
        List.map abbreviateNumberTest
          [ (123, "123")
          , (18000, "18K")
          , (150000, "150K")
          , (900000, "900K")
          , (5300000, "5.30M")
          , (123456789, "123.45M")
          , (74000000, "74.00M")
          , (9000000000, "9.00B")
          ]
    , describe "intToPunctuated" <|
        List.map intToPunctuatedTest
          [ (12345, "12,345")
          , (500000, "500,000")
          , (600, "600")
          , (1, "1")
          , (9876543210, "9,876,543,210")
          ]
    ]


abbreviateNumberTest : (Int, String) -> Test
abbreviateNumberTest (number, expectedResult) =
  test (toString number) <|
    \() ->
      Expect.equal expectedResult (NumberFormatter.abbreviateNumber number)


intToPunctuatedTest : (Int, String) -> Test
intToPunctuatedTest (number, expectedResult) =
  test (toString number) <|
    \() ->
      Expect.equal expectedResult (NumberFormatter.intToPunctuated number)
