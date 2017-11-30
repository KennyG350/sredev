module UrlQueryParser exposing (..)


import Regex exposing (find, regex, replace, HowMany(..))
import Http exposing (decodeUri)
import Maybe exposing (andThen, withDefault)
import String
import Json.Encode as JE
import List exposing (foldl)


type alias Url = String
type alias QueryString = String
type alias QueryParam = String


{-| Extract a query parameter from a query string.

    getQueryParam "foo=bar&baz=12345" "foo" == Just "bar"
    getQueryParam "foo=bar&baz=12345" "baz" == Just "12345"
    getQueryParam "foo=bar&baz=12345" "qux" == Nothing
-}
getQueryParam : QueryString -> QueryParam -> Maybe String
getQueryParam queryString paramName =
  List.head
    (
      find
        (AtMost 1)
        (regex <| paramName ++ "=([^?&]+)")
        queryString
    )
  |> andThen (.submatches >> List.head)
  |> andThen identity -- Value is (Just Just val) at this point; unpack to (Just val)
  |> andThen decodeUri


{-| Remove a query parameter from a query string.

    removeQueryParam "foo" "foo=bar&baz=12345" == "baz=12345"
    removeQueryParam "min_baths" "view=table&min_baths=4" == "view=table"
-}
removeQueryParam : QueryParam -> QueryString -> QueryString
removeQueryParam queryParam queryString =
  queryString
  |> replace All (regex <| queryParam ++ "=[^&]*[&]*") (always "") -- Remove "foo=bar" part
  |> replace All (regex "[&?]$") (always "") -- Remove potential trailing & or ?


removeEmptyQueryParams : QueryString -> QueryString
removeEmptyQueryParams queryString =
  queryString
  |> replace All (regex "[^\\=\\&\\?]+=&") (always "") -- Remove empty query params except at the end
  |> replace All (regex "[^\\=\\&\\?]+=$") (always "") -- Remove empty query param at the end


{-| Set a query param in a query string. (Removes instances of the param first.)

    setQueryParam "color" "green" "foo=bar&baz=qux" == "foo=bar&baz=qux&color=green"
    setQueryParam "color" "green" "color=blue&foo=bar&baz=qux" == "foo=bar&baz=qux&color=green"
    setQueryParam "colors" "green" "colors[]=blue&foo=bar&colors[]=red&baz=qux" == "foo=bar&baz=qux&color=green"
-}
setQueryParam : QueryParam -> String -> QueryString -> QueryString
setQueryParam queryParam value queryString =
  let
    queryString_ = removeQueryParam queryParam queryString
    prefix =
      case String.length queryString_ of
        0 ->
          "?"

        _ ->
          "&"
  in
    queryString_ ++ prefix ++ queryParam ++ "=" ++ value


{-| Take a url and remove the query params.

    removeUrlQueryParams "http://example.com/foo?bar=baz&qux=123" == "http://example.com/foo"
-}
removeUrlQueryParams : Url -> Url
removeUrlQueryParams =
  replace All (regex "(\\?.*)\\w+") (always "")


{- Remove the question mark from the location.search field
-}
removeQuestionMark : String -> String
removeQuestionMark =
  replace All (regex "\\?") (always "")


{-| Given a query string and a list of params to extract, return a list of
    (String, JE.Value) tuples ready to be passed to JE.object.

    Leaving it to the client to call JE.object allows for it to add to the list.
-}
toJsonValueList : List QueryParam -> QueryString -> List (String, JE.Value)
toJsonValueList queryParams queryString =
  foldl (jsonValueAccumulator queryString) [] queryParams


{-| Given a query string and a list of params to extract, return a JSON object
    built from the key-value pairs in the query string.
-}
toJsonObject : List QueryParam -> QueryString -> JE.Value
toJsonObject queryParams queryString =
  toJsonValueList queryParams queryString
  |> JE.object


jsonValueAccumulator : QueryString -> QueryParam -> List (QueryParam, JE.Value) -> List (QueryParam, JE.Value)
jsonValueAccumulator queryString queryParam jsonValues =
  case getQueryParam queryString queryParam of
    Just value ->
      (queryParam, JE.string value) :: jsonValues

    Nothing ->
      jsonValues


{-| Recursively decode a URI over and over until it stops changing. (Ensure it's fully decoded.)
-}
decodeUriCompletely : String -> String
decodeUriCompletely uri =
  case decodeUri uri of
    Just decodedUri ->
      if decodedUri == uri then
        uri

      else
        decodeUriCompletely decodedUri

    Nothing ->
      uri
