module Ports.GoogleMaps.Style exposing (
  Style,
  FeatureType(..),
  ElementType(..),
  Styler(..),
  Visibility(..),
  toJson,
  hexToColor)


import Color exposing (lightPurple)
import Color.Convert
import Json.Encode as JE


type alias Style =
  { featureType : FeatureType
  , elementType : ElementType
  , stylers : List Styler
  }


type FeatureType
  = AllFeatures
  | Administrative
  | AdministrativeCountry
  | AdministrativeLandParcel
  | AdministrativeLocality
  | AdministrativeNeighborhood
  | AdministrativeProvince
  | Landscape
  | LandscapeManMade
  | LandscapeNatural
  | LandscapeNaturalLandcover
  | LandscapeNaturalTerrain
  | Poi
  | PoiAttraction
  | PoiBusiness
  | PoiGovernment
  | PoiMedical
  | PoiPark
  | PoiPlaceOfWorship
  | PoiSchool
  | PoiSportsComplex
  | Road
  | RoadArterial
  | RoadHighway
  | RoadHighwayControlledAccess
  | RoadLocal
  | Transit
  | TransitLine
  | TransitStation
  | TransitStationAirport
  | TransitStationBus
  | TransitStationRail
  | Water


type ElementType
  = AllElements
  | Geometry
  | GeometryFill
  | GeometryStroke
  | Labels
  | LabelsIcon
  | LabelsText
  | LabelsTextFill
  | LabelsTextStroke


-- https://developers.google.com/maps/documentation/javascript/style-reference#stylers
-- Invalid values (lying outside the valid range) will be coerced to the nearest valid value.
type Styler
  = Color (Color.Color)
  | Gamma Float -- a floating point value between 0.01 and 10.0, where 1.0 applies no correction
  | Hue (Color.Color)
  | Lightness Float -- a floating point value between -100 and 100 (-100 == black, 100 == white)
  | Saturation Float -- a floating point value between -100 and 100
  | Visibility Visibility
  | Weight Float -- An integer value, >= zero. Sets the weight of the feature, in pixels.


type Visibility
  = VisibilityOn
  | VisibilityOff
  | VisibilitySimplified -- "removes some style features from the affected features"


featureTypeToString : FeatureType -> String
featureTypeToString featureType =
  case featureType of
    AllFeatures ->
      "all"

    Administrative ->
      "administrative"

    AdministrativeCountry ->
      "administrative.country"

    AdministrativeLandParcel ->
      "administrative.land_parcel"

    AdministrativeLocality ->
      "administrative.locality"

    AdministrativeNeighborhood ->
      "administrative.neighborhood"

    AdministrativeProvince ->
      "administrative.province"

    Landscape ->
      "landscape"

    LandscapeManMade ->
      "landscape.man_made"

    LandscapeNatural ->
      "landscape.natural"

    LandscapeNaturalLandcover ->
      "landscape.natural.landcover"

    LandscapeNaturalTerrain ->
      "landscape.natural.terrain"

    Poi ->
      "poi"

    PoiAttraction ->
      "poi.attraction"

    PoiBusiness ->
      "poi.business"

    PoiGovernment ->
      "poi.government"

    PoiMedical ->
      "poi.medical"

    PoiPark ->
      "poi.park"

    PoiPlaceOfWorship ->
      "poi.place_of_worship"

    PoiSchool ->
      "poi.school"

    PoiSportsComplex ->
      "poi.sports_complex"

    Road ->
      "road"

    RoadArterial ->
      "road.arterial"

    RoadHighway ->
      "road.highway"

    RoadHighwayControlledAccess ->
      "road.highway.controlled_access"

    RoadLocal ->
      "road.local"

    Transit ->
      "transit"

    TransitLine ->
      "transit.line"

    TransitStation ->
      "transit.station"

    TransitStationAirport ->
      "transit.station.airport"

    TransitStationBus ->
      "transit.station.bus"

    TransitStationRail ->
      "transit.station.rail"

    Water ->
      "water"


elementTypeToString : ElementType -> String
elementTypeToString elementType =
  case elementType of
    AllElements ->
      "all"

    Geometry ->
      "geometry"

    GeometryFill ->
      "geometry.fill"

    GeometryStroke ->
      "geometry.stroke"

    Labels ->
      "labels"

    LabelsIcon ->
      "labels.icon"

    LabelsText ->
      "labels.text"

    LabelsTextFill ->
      "labels.text.fill"

    LabelsTextStroke ->
      "labels.text.stroke"


visibilityToString : Visibility -> String
visibilityToString visibility =
  case visibility of
    VisibilityOn ->
      "on"

    VisibilityOff ->
      "off"

    VisibilitySimplified ->
      "simplified"


toJson : Style -> JE.Value
toJson { featureType, elementType, stylers } =
  JE.object
    [ ("featureType", JE.string <| featureTypeToString featureType)
    , ("elementType", JE.string <| elementTypeToString elementType)
    , ("stylers", JE.list <| List.map stylerToJson stylers)
    ]


stylerToJson : Styler -> JE.Value
stylerToJson styler =
  case styler of
    Color color ->
      color
      |> Color.Convert.colorToHex
      |> jsonObjectWithString "color"

    Gamma gamma ->
      gamma
      |> max 0.01
      |> min 10.0
      |> jsonObjectWithFloat "gamma"

    Hue color ->
      color
      |> Color.Convert.colorToHex
      |> jsonObjectWithString "hue"

    Lightness lightness ->
      lightness
      |> max -100
      |> min 100
      |> jsonObjectWithFloat "lightness"

    Saturation saturation ->
      saturation
      |> max -100
      |> min 100
      |> jsonObjectWithFloat "saturation"

    Visibility visibility ->
      visibility
      |> visibilityToString
      |> jsonObjectWithString "visibility"

    Weight weight ->
      weight
      |> max 0
      |> jsonObjectWithFloat "weight"


jsonObjectWithString : String -> String -> JE.Value
jsonObjectWithString = jsonObjectWithProperty JE.string


jsonObjectWithFloat : String -> Float -> JE.Value
jsonObjectWithFloat = jsonObjectWithProperty JE.float


jsonObjectWithProperty : (a -> JE.Value) -> String -> a -> JE.Value
jsonObjectWithProperty encode propertyName value =
  JE.object
    [ (propertyName, encode value)
    ]


hexToColor : String -> Color.Color
hexToColor hex =
  case Color.Convert.hexToColor hex of
    Ok color ->
      color

    Err _ ->
      lightPurple
