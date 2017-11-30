module MapPosition exposing (..)


import String
import List
import Ports.GoogleMaps exposing (..)


type MapPosition
  = Bounds LatLngBounds
  | Center LatLng


{-| Get a MapPosition from a position string in `south,west,north,east` or `lat,lng` format.

    fromString "37.12,-122.04,37.46,-121.58" == Ok (Bounds ({lat = 37.12, lng = -122.04}, {lat = 37.46, lng = -121.58}))
    fromString "39.25,-121.49" == Ok (Center {lat = 39.25, lng = -121.49})
    fromString "not a position string" == Err "Map position string not in `south,west,north,east` or `lat,lng` format."
    fromString "39.25&-121.49" == Err "Map position string not in `south,west,north,east` or `lat,lng` format."
-}
fromString : String -> Result String MapPosition
fromString positionString =
  case List.map String.toFloat <| String.split "," positionString of
    [Ok lat, Ok lng] ->
      Ok <| Center <| LatLng lat lng

    [Ok south, Ok west, Ok north, Ok east] ->
      Ok <| Bounds <| (LatLng south west, LatLng north east)

    _ ->
      Err "Map position string not in `south,west,north,east` or `lat,lng` format."


{-| Serialize a MapPosition to a string.

    toString_ (Bounds ({ lat = -12.34, lng = 56.78 }, { lat = 98.76, lng = -54.32 })) == "-12.34,56.78,98.76,-54.32"
    toString_ (Center ({ lat = 126.44, lng = -33.89 })) == "126.44,-33.89"
-}
toString_ : MapPosition -> String
toString_ mapPosition =
  case mapPosition of
    Bounds (southwest, northeast) ->
      String.join
        ","
        [ toString southwest.lat
        , toString southwest.lng
        , toString northeast.lat
        , toString northeast.lng
        ]

    Center { lat, lng } ->
      (toString lat) ++ "," ++ (toString lng)
