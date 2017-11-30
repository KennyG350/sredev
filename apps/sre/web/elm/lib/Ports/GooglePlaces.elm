port module Ports.GooglePlaces exposing (..)


import Json.Encode as JE
import Json.Decode as JD exposing (Decoder)
import Maybe exposing (withDefault)


type alias AutocompletePrediction =
  { description : String
  , place_id : String
  , terms : List PredictionTerm
  , types : List String
  }


type alias PredictionTerm =
  { offset : Float
  , value : String
  }


type alias PlaceResult =
  { bounds : String
  , formatted_address : String
  , geometry : PlaceGeometry
  , name : String
  , place_id : String
  , types : List String
  , vicinity : Maybe String
  }


type alias GeocoderAddressComponent =
  { long_name : String
  , short_name : String
  , types : List String
  }


type alias PlaceGeometry =
  { location : LatLng
  }


type alias LatLng =
  { lat : Float
  , lng : Float
  }


type alias SearchQuery = String

{-| "Four types are supported:
      'establishment' for businesses,
      'geocode' for addresses,
      '(regions)' for administrative regions,
      '(cities)' for localities."
-}
type alias PredictionType = String


type alias ComponentRestrictions =
  { country : String
  }

-- Send to JS (Cmd)
port requestGooglePlacesDetails : String -> Cmd msg
port requestGooglePlacesPredictions : (SearchQuery, List PredictionType, ComponentRestrictions) -> Cmd msg


-- Receive from JS (Sub)
port receiveGooglePlacesDetails : (PlaceResult -> msg) -> Sub msg
port receiveGooglePlacesPredictions : (List AutocompletePrediction -> msg) -> Sub msg


{-| JSON Encoding -}

encodePlaceResult : PlaceResult -> JE.Value
encodePlaceResult placeResult =
  JE.object
    [ ("bounds", JE.string placeResult.bounds)
    , ("formatted_address", JE.string placeResult.formatted_address)
    , ("geometry", encodePlaceGeometry placeResult.geometry)
    , ("name", JE.string placeResult.name)
    , ("place_id", JE.string placeResult.place_id)
    , ("types", encodeStringList placeResult.types)
    , ("vicinity", JE.string <| withDefault "" placeResult.vicinity)
    ]


placeResultDecoder : Decoder PlaceResult
placeResultDecoder =
  JD.map7 PlaceResult
    (JD.field "bounds" JD.string)
    (JD.field "formatted_address" JD.string)
    (JD.field "geometry" placeGeometryDecoder)
    (JD.field "name" JD.string)
    (JD.field "place_id" JD.string)
    (JD.field "types" <| JD.list JD.string)
    (JD.field "vicinity" <| JD.maybe JD.string)


encodePlaceGeometry : PlaceGeometry -> JE.Value
encodePlaceGeometry placeGeometry =
  JE.object
    [ ("location", encodeLatLng placeGeometry.location)
    ]


placeGeometryDecoder : Decoder PlaceGeometry
placeGeometryDecoder =
  JD.map PlaceGeometry
    (JD.field "location" latLngDecoder)


latLngDecoder : Decoder LatLng
latLngDecoder =
  JD.map2 LatLng
    (JD.field "lat" JD.float)
    (JD.field "lng" JD.float)


encodeLatLng : LatLng -> JE.Value
encodeLatLng latLng =
  JE.object
    [ ("lat", JE.float latLng.lat)
    , ("lng", JE.float latLng.lng)
    ]


encodeStringList : List String -> JE.Value
encodeStringList =
  (List.map JE.string) >> JE.list
