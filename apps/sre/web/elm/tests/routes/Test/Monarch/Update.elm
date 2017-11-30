module Test.Monarch.Update exposing (tests)


import Test exposing (test, describe, Test)
import Expect
import Navigation
import Monarch.Update exposing (locationMatchesRegex)
import Monarch.Types exposing (Route, RouteStrategy(..))


tests : Test
tests =
  describe "Monarch.Update"
    [ describe "locationMatchesRegex"
        [ test "Route paths match on location.pathname" <|
            \() ->
              "^/properties$"
              |> locationMatchesRegex
                   (
                     location
                       "/properties"
                       "?bounds=32.534856,-117.2821666,33.114249,-116.90816&location=San+Diego,+CA"
                   )
              |> Expect.equal True
        , test "Route paths don't match when they shouldn't" <|
            \() ->
              "^/foo$"
              |> locationMatchesRegex (location "/bar" "")
              |> Expect.equal False
        ]
    ]


location : String -> String -> Navigation.Location
location pathname search =
  { href = ""
  , host = ""
  , hostname = ""
  , protocol = ""
  , origin = ""
  , port_ = ""
  , pathname = pathname
  , search = search
  , hash = ""
  , username = ""
  , password = ""
  }
