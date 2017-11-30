module Routes exposing (routes)


import Json.Encode exposing (object, string, list, bool, null, float, int)
import Navigation exposing (Location)
import Monarch.Types exposing (..)
import Config


{-| Routes for launching Elm apps.

    See Monarch.Types for the full range of ElmApp and RouteStrategy types.

    App names can be namespaced within the name String using "." as such:
    Worker "Foo.Bar" corresponds to `module Foo.Bar`

    Monarch will launch EVERY route that matches, instead of just the first one it finds.
    This enables certain code to be launched depending on URL query parameters.
-}
routes : Location -> List Route
routes location =
  let
    encodedLocation = encodeLocation location
  in
    -- Global Apps
    [ Route Immediately
        [ Worker "LoginClickHandler"
        , Worker "MobileMenu"
        , Worker "UserActivityWorker"
        , WorkerWithFlags "PreventDoubleUrlEncoding" encodedLocation
        ]

    -- Home
    , Route (NewPageLoadWithUrl "^/$")
        [ Worker "FeedMaps"
        , WorkerWithFlags "HandleLoginError" encodedLocation
        , WorkerWithFlags "HandleInviteToken" encodedLocation
        , WorkerWithFlags "ListingFavoriteButton" <| object
            [ ("containerSelector", string "body")
            , ("favoritedClass", string "property-card__header__favorite--favorited")
            ]
        , WorkerWithFlags "ContactForm" <| object
            [ ("formSelector", string ".elm-message-form")
            , ("forSpecificListing", bool False)
            ]

        -- Buy calculator
        , WorkerWithFlags "Slider" <| object
            [ ("containerSelector", string ".elm-buy-calculator-slider")
            , ("knobSelector", string ".elm-buy-calculator-slider-knob")
            , ("rangeBarSelector", string ".elm-buy-calculator-touch-target")
            ]
        , WorkerWithFlags "BuyCalculator" <| object
            [ ("rebateMultiplier", float Config.rebateMultiplier)
            , ( "sliderOptions"
              , Config.buySliderOptions
                |> List.map int
                |> list
              )
            ]
        , EmbedWithFlags "BuyCalculator.GeoSuggest" ".elm-buy-calculator-geosuggest" <| object
            [ ("formSelector", string ".elm-buy-calculator-geosuggest-form")
            , ("inputSelector", string ".elm-buy-calculator-geosuggest-input input")
            ]
        ]

    -- Search
    , Route (NewPageLoadWithUrl "^/properties$")
        [ Embed "SearchViewSwitcher" ".elm-mobile-search-view-switcher"
        , WorkerWithFlags "ListingFavoriteButton" <| object
            [ ("containerSelector", string ".elm-search-properties-results")
            , ("favoritedClass", string "property-card__header__favorite--favorited")
            ]
        , WorkerWithFlags "SearchDispatcher" encodedLocation
        , Worker "SearchMap"
        , Worker "ListingList"
        , Worker "MultiUnitList"
        , Worker "SearchSort"
        , WorkerWithFlags "SaveSearch" encodedLocation
        , WorkerWithFlags "ListingDetailsModal" encodedLocation

        -- Filters
        , Worker "FiltersMenu"
        , Worker "Filters.PropertyType"
        , Worker "Filters.PriceRange"
        , Worker "Filters"
        , WorkerWithFlags "Filters.RangeSlider" <| object
            [ ("sliderSelector", string ".elm-range-slider")
            , ("innerBarSelector", string ".elm-range-slider-inner-bar")
            ]
        , WorkerWithFlags "Filters.Room" <| object
            [ ("containerSelector", string ".elm-filters-room-bedrooms")
            ]
        , WorkerWithFlags "Filters.Room" <| object
            [ ("containerSelector", string ".elm-filters-room-bathrooms")
            ]
        ]

    -- Listing details modal
    , Route (OnBroadcast Config.launchListingDetailsModalMessage) <|
        listingDetailsApps ".elm-search-property-contents"

    -- Listing details expanded
    , Route (NewPageLoadWithUrl "^/properties/.+") <|
        listingDetailsApps "body"

    , Route (NewPageLoadWithUrl "^/buy")
        [ EmbedWithFlags "GeoSuggest" ".elm-buy-calculator-geosuggest" <| object
            [ ("defaultValue", null)
            , ("formSelector", string ".elm-buy-calculator-geosuggest-form")
            , ("inputSelector", string ".elm-buy-calculator-geosuggest-input")
            , ("locationSelectedMessage", string "buyCalculatorLocationSelected")
            , ("immediatelySelectMessage", null)
            , ("predictionTypes", list [])
            , ("pathOnPredictionSelected", null)
            , ("setBoundsParamOnPredictionSelected", bool False)
            , ("location", encodedLocation)
            ]
        , WorkerWithFlags "BuyCalculator" <| object
            [ ("rebateMultiplier", float Config.rebateMultiplier)
            , ( "sliderOptions"
              , Config.buySliderOptions
                |> List.map int
                |> list
              )
            ]
        , WorkerWithFlags "Slider" <| object
            [ ("containerSelector", string ".elm-buy-calculator-slider")
            , ("knobSelector", string ".elm-buy-calculator-slider-knob")
            , ("rangeBarSelector", string ".elm-buy-calculator-touch-target")
            ]
        , Worker "BuyCalculator.Label"
        , Worker "BuyCalculator.ListingSearch"
        , WorkerWithFlags "ContactForm" <| object
            [ ("formSelector", string ".elm-message-form")
            , ("forSpecificListing", bool False)
            ]
        ]

    , Route (NewPageLoadWithUrl "^/contact")
        [ WorkerWithFlags "ContactForm" <| object
            [ ("formSelector", string ".elm-message-form")
            , ("forSpecificListing", bool False)
            ]
        ]

    , Route (NewPageLoadWithUrl "^/sell")
        [ WorkerWithFlags "ContactForm" <| object
            [ ("formSelector", string ".elm-message-form")
            , ("forSpecificListing", bool False)
            ]
        , WorkerWithFlags "SellCalculator" <| object
            [ ("initialPrice", float Config.sellCalculatorInitialPrice)
            , ("initialPercent", float Config.sellCalculatorInitialPercent)
            ]
        ]

    , Route (NewPageLoadWithUrl "^/mysre/favorites")
        [ WorkerWithFlags "ListingFavoriteButton" <| object
            [ ("containerSelector", string "body")
            , ("favoritedClass", string "property-card__header__favorite--favorited")
            ]
        ]
    ]


encodeLocation : Navigation.Location -> Json.Encode.Value
encodeLocation location =
  Json.Encode.object
    [ ("href", Json.Encode.string location.href)
    , ("host", Json.Encode.string location.host)
    , ("hostname", Json.Encode.string location.hostname)
    , ("protocol", Json.Encode.string location.protocol)
    , ("origin", Json.Encode.string "") -- location.origin is debug-output as `<internal structure>` and sent as `undefined` in IE10
    , ("port_", Json.Encode.string location.port_)
    , ("pathname", Json.Encode.string location.pathname)
    , ("search", Json.Encode.string location.search)
    , ("hash", Json.Encode.string location.hash)
    , ("username", Json.Encode.string "") -- location.username is debug-output as `<internal structure>` and sent as `undefined`
    , ("password", Json.Encode.string "") -- location.password is debug-output as `<internal structure>` and sent as `undefined`
    ]


listingDetailsApps : String -> List ElmApp
listingDetailsApps favoriteButtonsContainer =
  [ WorkerWithFlags "ListingFavoriteButton" <| object
      [ ("containerSelector", string favoriteButtonsContainer)
      , ("favoritedClass", string "property-aside__favorite--favorited")
      ]
  , WorkerWithFlags "ContactForm" <| object
      [ ("formSelector", string ".elm-property-contact-form")
      , ("forSpecificListing", bool True)
      ]
  , Worker "ImageSliderAspectRatio"
  , Worker "WalkScore"
  , Worker "PropertyHeroImageSlider"
  , Worker "PropertyHeroMap"
  , Worker "PropertyHeroViewSwitcher"
  , Worker "DisplayContactForm"
  ]
