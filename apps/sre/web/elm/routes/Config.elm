module Config exposing (..)


import Json.Encode as JE
import Color exposing (white, black)
import Ports.GoogleMaps.Style as Style exposing (Style, FeatureType(..), ElementType(..), Styler(..), Visibility(..), hexToColor)


sellCalculatorInitialPrice : Float
sellCalculatorInitialPrice = 475000


sellCalculatorInitialPercent : Float
sellCalculatorInitialPercent = 0.01


buyCalculatorSearchBoxSize : Float -- Size of search box in Miles
buyCalculatorSearchBoxSize = 3


rebateMultiplier : Float
rebateMultiplier = 0.02


buySliderOptions : List Int
buySliderOptions =
  let
    getMultiples multiplier = List.map (\x -> multiplier * x)
  in
    getMultiples 10000 (List.range 10 50) -- Multiples of 10k from 100k to 500k
    ++ getMultiples 25000 (List.range 21 30) -- Multiples of 25k from 525k to 750k
    ++ getMultiples 50000 (List.range 16 20) -- Multiples of 50k from 800k to 1M
    ++ getMultiples 100000 (List.range 11 25) -- Multiples of 100k from 1.1M to 2.5M
    ++ getMultiples 250000 (List.range 11 20) -- Multiples of 250k from 2.75M to 5M
    ++ getMultiples 1000000 (List.range 6 10) -- Multiples of 1M from 6M to 10M


buyCalculatorUnderMillionRangeSpread : Float
buyCalculatorUnderMillionRangeSpread = 0.15


buyCalculatorOverMillionRangeSpread : Float
buyCalculatorOverMillionRangeSpread = 0.1


buyCalculatorSearchThrottleSpeed : Float
buyCalculatorSearchThrottleSpeed = 1000


buyCalculatorInitialPrice : Float
buyCalculatorInitialPrice = 500000


listingModalQueryParam : String
listingModalQueryParam = "property"


boundsQueryParam : String
boundsQueryParam = "bounds"


favoriteListingButtonSelectorPrefix : String
favoriteListingButtonSelectorPrefix = ".elm-favorite-listing-button-"


-- All classes used to mark a "favorite" button as favorited
favoriteListingButtonFavoritedClasses : List String
favoriteListingButtonFavoritedClasses =
  [ "property-card__header__favorite--favorited"
  , "property-aside__favorite--favorited"
  ]


launchListingDetailsModalMessage : String
launchListingDetailsModalMessage = "launchListingDetailsModal"


-- Selectors for meta tags that contain the user's location
locationBoundsMetaTagSelector : String
locationBoundsMetaTagSelector = "meta[name='user-location-bounds']"


locationMetaTagSelector : String
locationMetaTagSelector = "meta[name='user-location']"


imageSlider16By9ContainerSelector : String
imageSlider16By9ContainerSelector = ".elm-image-slider-16by9-container"


imageSliderImageSelector : String
imageSliderImageSelector = ".elm-image-slider-image"


image16By9Multiplier : Float
image16By9Multiplier = 0.5625


contactFormLocalStorageKey : String
contactFormLocalStorageKey = "contactFormContactInformation"


loginErrorMessage : String
loginErrorMessage = "We encountered a problem logging you in"


defaultMapStyles : List JE.Value
defaultMapStyles =
  [ Style LandscapeManMade Geometry [Color <| hexToColor "#f7f1df"]
  , Style LandscapeNatural Geometry [Color <| hexToColor "#d0e3b4"]
  , Style LandscapeNaturalTerrain Geometry [Visibility VisibilityOff]
  , Style Poi Labels [Visibility VisibilityOff]
  , Style PoiBusiness AllElements [Visibility VisibilityOff]
  , Style PoiMedical Geometry [Color <| hexToColor "#fbd3da"]
  , Style PoiPark Geometry [Color <| hexToColor "#bde6ab"]
  , Style Road GeometryStroke [Visibility VisibilityOff]
  , Style Road Labels [Visibility VisibilityOn]
  , Style Road LabelsIcon [Visibility VisibilitySimplified, Lightness 0, Gamma 1.0]
  , Style RoadHighway GeometryFill [Color <| hexToColor "#ffe15f"]
  , Style RoadHighway GeometryStroke [Color <| hexToColor "#efd151"]
  , Style RoadArterial GeometryFill [Color white]
  , Style RoadLocal GeometryFill [Color white]
  , Style TransitStationAirport GeometryFill [Color <| hexToColor "#cfb2db"]
  , Style Water Geometry [Color <| hexToColor "#a2daf2"]
  ]
  |> List.map Style.toJson
