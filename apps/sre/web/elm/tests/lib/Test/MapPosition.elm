module Test.MapPosition exposing (tests)


import Test exposing (test, Test, describe)
import List
import MapPosition exposing (MapPosition(..))
import Ports.GoogleMaps exposing (LatLng)
import Expect


tests : Test
tests =
  describe "MapPosition"
    [ describe "fromString"
        [ describe "Valid string formats yield MapPositions" <|
            List.map fromStringTest
              [ ("1,2", Ok <| Center <| LatLng 1 2)
              , ("-116.2301,32.3532", Ok <| Center <| LatLng -116.2301 32.3532)
              , ("1,2,3,4", Ok <| Bounds <| (LatLng 1 2, LatLng 3 4))
              , ( "-116.2301,32.3532,-113.8364,30.286222"
                , Ok <| Bounds <| (LatLng -116.2301 32.3532, LatLng -113.8364 30.286222)
                )
              ]
        , describe "Invalid string formats yield an Err" <|
            List.map fromStringErrTest
              [ "asdf"
              , "1, 2"
              , "1, 2, 3, 4"
              , "112.123&25.334"
              ]
        ]
    ]


fromStringTest : (String, Result String MapPosition) -> Test
fromStringTest (aString, expectedResult) =
  test aString <|
    \() ->
      Expect.equal expectedResult (MapPosition.fromString aString)


fromStringErrTest : String -> Test
fromStringErrTest aString =
  test aString <|
    \() ->
      let
        result = MapPosition.fromString aString
        passed =
          case result of
            Err _ ->
               True

            Ok _ ->
              False
      in
        Expect.true "Expected MapPosition.fromString to yield an Err" passed
