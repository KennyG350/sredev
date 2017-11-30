module UserActivity exposing (..)


type alias ListingId = String
type alias ListingUrl = String


type UserActivity
  = FavoriteListing ListingId
  | UnfavoriteListing ListingId
  | ViewedListing ListingUrl
