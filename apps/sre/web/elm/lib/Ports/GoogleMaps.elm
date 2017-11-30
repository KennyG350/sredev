port module Ports.GoogleMaps exposing (..)


import Json.Decode as JD
import Json.Encode as JE


type alias Selector = String
type alias BoundsUrlValue = String


type alias CreateMapOptions =
  { center : Maybe LatLng
  , disableDefaultUI : Maybe Bool
  , mapTypeControlPosition : Maybe String
  , mapTypeId : Maybe String
  , maxZoom : Maybe Int
  , minZoom : Maybe Int
  , rotateControlPosition : Maybe String
  , scrollWheel : Maybe Bool
  , signInControl : Maybe Bool
  , streetViewControlPosition : Maybe String
  , styles : List JD.Value
  , zoom : Maybe Int
  , zoomControlPosition : Maybe String
  }


type alias LatLng =
  { lat : Float
  , lng : Float
  }


type alias LatLngBounds =
  (LatLng, LatLng) -- (southwest, northeast) just like the Google Maps library APIs


type alias PropertyMarker =
  { latLng : LatLng
  , price : Float
  , url : String
  }


type alias Marker =
  { latLng : LatLng
  , name : String
  }


-- Subscriptions (Receive from JS)
port createMapFinished : (Selector -> msg) -> Sub msg
port dragEnd : ((Selector, BoundsUrlValue) -> msg) -> Sub msg
port zoomChanged : ((Selector, BoundsUrlValue) -> msg) -> Sub msg
port idle : ((Selector, BoundsUrlValue) -> msg) -> Sub msg


-- Commands (Send to JS)
port createMap : (Selector, CreateMapOptions) -> Cmd msg
port fitBounds : (Selector, LatLngBounds) -> Cmd msg
port setCenter : (Selector, LatLng) -> Cmd msg
port setZoom : (Selector, Int) -> Cmd msg
port addPropertyMarkers : (Selector, List PropertyMarker) -> Cmd msg
port addMarkers : (Selector, List Marker) -> Cmd msg
port clearMarkers : Selector -> Cmd msg


emptyCreateMapOptions : CreateMapOptions
emptyCreateMapOptions =
  CreateMapOptions
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    []
    Nothing
    Nothing


optionsFromCenter : LatLng -> CreateMapOptions
optionsFromCenter latLng =
  CreateMapOptions
    (Just latLng)
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    []
    Nothing
    Nothing


optionsFromStyles : List JD.Value -> CreateMapOptions
optionsFromStyles styles =
  CreateMapOptions
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    styles
    Nothing
    Nothing


emptyPropertyMarker : PropertyMarker
emptyPropertyMarker =
  PropertyMarker (LatLng 0 0) 0 ""


propertyMarkerDecoder : JD.Decoder PropertyMarker
propertyMarkerDecoder =
  JD.map3 PropertyMarker
    (JD.field "latLng" latLngDecoder)
    (JD.field "price" JD.float)
    (JD.field "url" JD.string)


latLngBoundsToJson : LatLngBounds -> JE.Value
latLngBoundsToJson (southwest, northeast) =
  JE.list
    [ latLngToJson southwest
    , latLngToJson northeast
    ]


latLngBoundsDecoder : JD.Decoder LatLngBounds
latLngBoundsDecoder =
  JD.map2 (,)
    (JD.index 0 latLngDecoder)
    (JD.index 1 latLngDecoder)


latLngToJson : LatLng -> JE.Value
latLngToJson { lat, lng } =
  JE.object
    [ ("lat", JE.float lat)
    , ("lng", JE.float lng)
    ]


latLngDecoder : JD.Decoder LatLng
latLngDecoder =
  JD.map2 LatLng
    (JD.field "lat" JD.float)
    (JD.field "lng" JD.float)


{-| Get a LatLngBounds from a position string in `south,west,north,east` format.

    fromString "37.12,-122.04,37.46,-121.58" == Just ({lat = 37.12, lng = -122.04}, {lat = 37.46, lng = -121.58})
    fromString "not a bounds string" == Nothing
-}
latLngBoundsFromString : String -> Maybe LatLngBounds
latLngBoundsFromString boundsString =
  case List.map String.toFloat <| String.split "," boundsString of
    [Ok south, Ok west, Ok north, Ok east] ->
      Just (LatLng south west, LatLng north east)

    _ ->
      Nothing


{-| Serialize a LatLngBounds to a string.

    latLngBoundsToString ({ lat = -12.34, lng = 56.78 }, { lat = 98.76, lng = -54.32 })) == "-12.34,56.78,98.76,-54.32"
-}
latLngBoundsToString : LatLngBounds -> String
latLngBoundsToString (southwest, northeast) =
  String.join
    ","
    [ toString southwest.lat
    , toString southwest.lng
    , toString northeast.lat
    , toString northeast.lng
    ]


{-| Return a slightly smaller bounding box than the one input.

    (Each boundary is moved toward the center `shrinkBoundsPercentage` percent.)
-}
slightlyShrinkBounds : LatLngBounds -> LatLngBounds
slightlyShrinkBounds (southwest, northeast) =
  let
    latAdjustment = shrinkAmount southwest.lat northeast.lat
    lngAdjustment = shrinkAmount southwest.lng northeast.lng
  in
    ( LatLng
        (southwest.lat + latAdjustment)
        (southwest.lng + lngAdjustment)
    , LatLng
        (northeast.lat - latAdjustment)
        (northeast.lng - lngAdjustment)
    )


{-| Compute the amount by which to "shrink" a bounding box.

    (This is actually half the amount to shrink the *box*; it's the amount
    to move each boundary toward the center.)

    Finds the different between the two points and returns a percentage of that distance.
    (Percentage is `shrinkBoundsPercentage`.)
-}
shrinkAmount : Float -> Float -> Float
shrinkAmount latOrLng1 latOrLng2 =
  (latOrLng1 - latOrLng2)
  |> abs
  |> (*) shrinkBoundsPercentage


{-| Values between 0.1 and 0.28 seem to work.

    Any lower and the map will zoom out too much.
    Any higher and it will zoom in too much.
-}
shrinkBoundsPercentage : Float
shrinkBoundsPercentage = 0.14 -- 14%
