module Test.Device exposing (tests)


import String
import List
import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import Device exposing (Device(..))


tests : Test
tests =
  describe "Device"
    [ describe "fromString"
        [ describe "Various casings of 'mobile'" <|
            List.map expectMobileTest
              [ "mobile"
              , "Mobile"
              , "MOBILE"
              , "mobILE"
              ]
        , describe "Various casings of 'desktop'" <|
            List.map expectDesktopTest
              [ "desktop"
              , "Desktop"
              , "DESKTOP"
              , "dESkTop"
              ]
        , fuzz (string) "Strings that don't lowercase to `mobile` are Desktop" <|
            \aString ->
              if String.toLower aString == "mobile" then
                Expect.equal Mobile (Device.fromString aString)

              else
                Expect.equal Desktop (Device.fromString aString)
        ]
    ]


expectMobileTest : String -> Test
expectMobileTest aString =
  test aString <|
    \() ->
      Expect.equal Mobile (Device.fromString aString)


expectDesktopTest : String -> Test
expectDesktopTest aString =
  test aString <|
    \() ->
      Expect.equal Desktop (Device.fromString aString)
