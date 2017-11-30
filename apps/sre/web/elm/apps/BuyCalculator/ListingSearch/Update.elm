module BuyCalculator.ListingSearch.Update exposing (update)


import Regex exposing (replace, regex, HowMany(..))
import Time
import Debounce
import Json.Encode as JE
import Json.Decode as JD
import Ports.Websocket as Websocket
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Ports.GooglePlaces as GooglePlaces
import DecodeHelper
import Config
import BuyCalculator.ListingSearch.Types exposing (..)
import BuyCalculator.ListingSearch.Types.PriceCategory exposing (medianFloatToRange)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveBroadcast ("buyCalculatorPriceUpdated", price) ->
      case JD.decodeValue JD.float price of
        Ok price_ ->
          let
            (throttleState, cmd) = Debounce.push debounceConfig price_ model.throttleState
          in
            ({ model | throttleState = throttleState, price = price_ }, cmd)

        Err _ ->
          model ! []

    ReceiveBroadcast ("newBuyCalculatorSearch", payload) ->
      case JD.decodeValue searchParamsDecoder payload of
        Ok searchParams ->
          { model | lastSearch = Just searchParams } ! []

        Err _ ->
          model ! []

    ReceiveBroadcast ("buyCalculatorLocationSelected", payload) ->
      case JD.decodeValue GooglePlaces.placeResultDecoder payload of
        Ok { bounds, formatted_address, geometry } ->
          let
            location = replace All (regex ", USA") (always "") formatted_address
          in
            ( { model | bounds = Just bounds, location = Just location }
            , requestListingsCmd bounds location model.price
            )

        Err _ ->
          model ! []

    QuerySelectorResponse (selector, { content }) ->
      case content of
        Just content_ ->
          if selector == Config.locationBoundsMetaTagSelector then
            { model | bounds = Just content_ } ! []

          else if selector == Config.locationMetaTagSelector then
            { model | location = Just content_ } ! []

          else
            model ! []

        Nothing ->
          model ! []

    ThrottleListingRequests throttleMsg ->
      case (model.bounds, model.location) of
        (Just bounds, Just location) ->
          let
            (throttleState, cmd) =
              Debounce.update debounceConfig
                (Debounce.takeLast <| requestListingsCmd bounds location)
                throttleMsg
                model.throttleState
          in
            ({ model | throttleState = throttleState }, cmd)

        _ ->
          model ! []

    WebsocketReceive ("listing_list", "receive_listing_list", payload) ->
      case DecodeHelper.decodeListingListResponse payload of
        Ok { view, total_results } ->
          let
            containerCmd =
              if total_results == 0 then
                Dom.setCssProperty (".elm-buy-calculator-search-results-container", "display", "none")

              else
                Dom.removeCssProperty (".elm-buy-calculator-search-results-container", "display")
          in
            model !
            [ Dom.innerHtml (".elm-buy-calculator-search-results", view)
            , Dom.innerHtml (".elm-buy-calculator-number-of-homes", toString total_results)
            , containerCmd
            , model.location
              |> Maybe.map (
                   \loc -> Dom.innerHtml (".elm-buy-calculator-location", loc)
                 )
              |> Maybe.withDefault Cmd.none
            , model.lastSearch
              |> Maybe.map searchUrl
              |> Maybe.map (
                   \url -> Dom.setProperty (".elm-buy-calculator-search-link", "href", JE.string url)
                 )
              |> Maybe.withDefault Cmd.none
            ]

        Err _ ->
          model ! []

    _ ->
      model ! []


requestListingsCmd : String -> String -> Float -> Cmd Msg
requestListingsCmd bounds location medianPrice =
  let
    (priceMin, priceMax) = medianFloatToRange medianPrice
  in
    Cmd.batch
      [ Websocket.websocketSend
          ( "listing_list"
          , "request_listing_list"
          , listingListRequest location bounds priceMin priceMax
          )
      , PubSub.broadcast
          ( "newBuyCalculatorSearch"
          , JE.object <|
              [ ("bounds", JE.string bounds)
              , ("location", JE.string location)
              , ( "priceMin"
                , priceMin
                  |> Maybe.map JE.float
                  |> Maybe.withDefault JE.null
                )
              , ( "priceMax"
                , priceMax
                  |> Maybe.map JE.float
                  |> Maybe.withDefault JE.null
                )
              ]
          )
      ]


listingListRequest : String -> String -> Maybe Float -> Maybe Float -> JE.Value
listingListRequest location bounds minPrice maxPrice =
  JE.object
    [ ("view", JE.string "homepage")
    , ("sort", JE.string "recent")
    , ("filters", JE.object <|
        [ ( "price_min"
          , minPrice
            |> Maybe.map toString
            |> Maybe.map JE.string
            |> Maybe.withDefault JE.null
          )
        , ( "price_max"
          , maxPrice
            |> Maybe.map toString
            |> Maybe.map JE.string
            |> Maybe.withDefault JE.null
          )
        , ("bounds", JE.string bounds)
        , ("location", JE.string location)
        ]
      )
    ]


debounceConfig : Debounce.Config Msg
debounceConfig =
  { strategy = Debounce.soon (Config.buyCalculatorSearchThrottleSpeed * Time.millisecond)
  , transform = ThrottleListingRequests
  }


searchUrl : SearchParams -> String
searchUrl { bounds, location, priceMin, priceMax } =
  let
    priceMinParam =
      priceMin
      |> Maybe.map round
      |> Maybe.map toString
      |> Maybe.map (\p -> "&price_min=" ++ p)
      |> Maybe.withDefault ""

    priceMaxParam =
      priceMax
      |> Maybe.map round
      |> Maybe.map toString
      |> Maybe.map (\p -> "&price_max=" ++ p)
      |> Maybe.withDefault ""
  in
  "/properties?bounds=" ++ bounds ++ "&location=" ++ location ++ priceMinParam ++ priceMaxParam
