module Route exposing (
  Route(..),
  fromLocation,
  fromPathname,
  fromPathnameAndSearch,
  isListingDetailsModal,
  toListingDetailsModal)


import Navigation exposing (Location)
import UrlParser exposing (string, parsePath, (</>), (<?>), s, oneOf, map, stringParam)
import Config


-- The segment of the URL after "/properties/" or the `property` value in "/properties?property=..."
type alias ListingSlug = String


type Route
  = Home
  | Search (Maybe ListingSlug) -- If ListingSlug is provided, we should be looking at the listing details modal
  | ListingDetails ListingSlug


fromLocation : Location -> Maybe Route
fromLocation location =
  parsePath route location


route : UrlParser.Parser (Route -> a) a
route =
  oneOf
    [ map Home (s "")
    , map Search (s "properties" <?> stringParam Config.listingModalQueryParam)
    , map ListingDetails (s "properties" </> string)
    ]


fromPathname : String -> Maybe Route
fromPathname pathname =
  fromPathnameAndSearch pathname ""


fromPathnameAndSearch : String -> String -> Maybe Route
fromPathnameAndSearch pathname search =
  fromLocation (Location "" "" "" "" "" "" pathname search "" "" "")


isListingDetailsModal : Route -> Bool
isListingDetailsModal route =
  case route of
    Search (Just _) ->
      True

    _ ->
      False


toListingDetailsModal : Route -> Maybe String
toListingDetailsModal route =
  case route of
    Search (Just listingUrlSlug) ->
      Just listingUrlSlug

    _ ->
      Nothing
