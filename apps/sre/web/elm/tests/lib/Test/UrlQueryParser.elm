module Test.UrlQueryParser exposing (tests)


import Http
import Test exposing (Test, test, fuzz, describe)
import Fuzz exposing (intRange)
import Expect
import UrlQueryParser


tests : Test
tests =
  describe "UrlQueryParser"
    [ describe "getQueryParam" <|
        List.map getQueryParamTest
          [ ("?foo=1&bar=2&baz=3", "foo", Just "1")
          , ("?foo=1&bar=2&baz=3", "bar", Just "2")
          , ("?foo=1&bar=2&baz=3", "baz", Just "3")
          , ("?foo=1&bar=2&baz=3", "qux", Nothing)
          ]
    , describe "removeQueryParam" <|
        List.map removeQueryParamTest
          [ ("?foo=1&bar=2", "foo", "?bar=2")
          , ("?foo=1&bar=2", "bar", "?foo=1")
          , ("?a=a&b=b&c=c", "b", "?a=a&c=c")
          ]
    , describe "setQueryParam" <|
        List.map setQueryParamTest
          [ ("?foo=bar", "foo", "notBar", "?foo=notBar")
          , ("?foo=1&bar=2", "foo", "ELSE", "?bar=2&foo=ELSE")
          , ("?foo=1&bar=2", "bar", "3", "?foo=1&bar=3")
          ]
    , describe "decodeUriCompletely"
        [ fuzz (intRange 1 50) "Completely decodes string regardless of encoding iterations" <|
            \anInt ->
              encodableQueryString
              |> encodeUri anInt
              |> UrlQueryParser.decodeUriCompletely
              |> Expect.equal encodableQueryString
        ]
    ]


getQueryParamTest : (String, String, Maybe String) -> Test
getQueryParamTest (queryString, paramName, expectedResult) =
  test (queryString ++ " (getting param) " ++ paramName) <|
    \() ->
      Expect.equal expectedResult (UrlQueryParser.getQueryParam queryString paramName)


removeQueryParamTest : (String, String, String) -> Test
removeQueryParamTest (queryString, queryParam, expectedResult) =
  test (queryString ++ " (removing param) " ++ queryParam) <|
    \() ->
      Expect.equal expectedResult (UrlQueryParser.removeQueryParam queryParam queryString)


setQueryParamTest : (String, String, String, String) -> Test
setQueryParamTest (queryString, queryParam, value, expectedResult) =
  test (queryString ++ " (setting param) " ++ queryParam ++ " (to value) " ++ value) <|
    \() ->
      Expect.equal expectedResult (UrlQueryParser.setQueryParam queryParam value queryString)


encodeUri : Int -> String -> String
encodeUri iterations string =
  if iterations < 1 then
    string

  else
    string
    |> Http.encodeUri
    |> encodeUri (iterations - 1)


encodableQueryString : String
encodableQueryString = "?bounds=12.222,34.444,56.666,78.888"
