module DecodeHelper exposing (..)


import Json.Decode as JD


type alias ListingListResponse =
  { page : Int
  , total_results : Int
  , view : String
  , saved_search : Maybe String
  }


decodeListingListResponse : JD.Value -> Result String ListingListResponse
decodeListingListResponse =
  JD.decodeValue
    <| JD.map4 ListingListResponse
        (JD.field "page" JD.int)
        (JD.field "total_results" JD.int)
        (JD.field "view" JD.string)
        (JD.field "saved_search" (JD.maybe JD.string))
