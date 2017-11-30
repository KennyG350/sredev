module Test.Route exposing (tests)


import Test exposing (test, describe, Test)
import Expect
import Route exposing (Route(..))
import Config


tests : Test
tests =
  describe "Route"
    [ describe "fromPathname" <|
        List.map fromPathnameTest
          [ ("/", "", Just Home)
          , ("/properties", "", Just (Search Nothing))
          , ( "/properties"
            , "?" ++ Config.listingModalQueryParam ++ "=foo-bar-baz"
            , Just <| Search <| Just "foo-bar-baz"
            )
          , ("/properties/foo", "", Just <| ListingDetails "foo")
          , ( "/properties/929-border-avenue-del-mar-ca-92014-69d33e42"
            , ""
            , Just <| ListingDetails "929-border-avenue-del-mar-ca-92014-69d33e42"
            )
          , ("Totally invalid URL", "", Nothing)
          ]
    ]


fromPathnameTest : (String, String, Maybe Route) -> Test
fromPathnameTest (aPathname, aSearch, expectedRoute) =
  test aPathname <|
    \() ->
      Expect.equal expectedRoute (Route.fromPathnameAndSearch aPathname aSearch)
