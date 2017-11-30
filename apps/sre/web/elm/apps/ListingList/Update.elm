module ListingList.Update exposing (update, clickListeners)


import Maybe exposing (withDefault, andThen)
import Json.Decode as JD
import Json.Encode as JE
import UrlQueryParser
import NumberFormatter
import Route exposing (Route(..))
import Ports.Websocket as Websocket
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import SearchParameters exposing (SearchParameters)
import Config
import ListingList.Types exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HandleClick (".pagination__button--prev", _, _) ->
      (model, PubSub.broadcastWithoutPayload "decrementedSearchPage")

    HandleClick (".pagination__button--next", _, _) ->
      (model, PubSub.broadcastWithoutPayload "incrementedSearchPage")

    HandleClick (".elm-listing-link", { pathname }, _) ->
      case pathname of
        Just pathname_ ->
          case Route.fromPathname pathname_ of
            Just (ListingDetails listingUrl) ->
              model !
              [ PubSub.broadcast ("listingClicked", JE.string listingUrl)
              ]

            _ ->
              model ! []

        Nothing ->
          model ! []

    ReceiveBroadcast ("performNewCardsSearch", searchParameters) ->
      searchParameters
      |> SearchParameters.fromJson
      |> \params ->
           model !
           [ Websocket.websocketSend
               ( "listing_list"
               , "request_listing_list"
               , listingListRequest params
               )
           , Dom.addClass (".elm-search-properties-loading", "search__properties__results--loading")
           ]

    ReceiveWebsocketMessage ("listing_list", "receive_listing_list", payload) ->
      case socketResponseDecoder payload of
        Ok response ->
          model !
          [ Dom.innerHtml ( ".elm-search-properties-results", response.view )
          , Dom.setProperty ( ".elm-search-result-scroll-target", "scrollTop", JE.int 0 )
          , Dom.windowScrollTo ( 0, 0 )
          , Dom.removeClass ( ".elm-search-properties-loading", "search__properties__results--loading" )
          , Dom.innerHtml ( ".elm-total-search-results", NumberFormatter.intToPunctuated response.total_results )
          ]

        Err error ->
          model ! []

    InnerHtmlReplaced ".elm-search-properties-results" ->
      model !
      [ Cmd.batch clickListeners
      , PubSub.broadcastWithoutPayload "newSearchResultsRendered"
      ]

    _ ->
      model ! []


listingListRequest : SearchParameters -> JE.Value
listingListRequest params =
  JE.object
    [ ("page", JE.string <| toString params.page)
    , ("view", JE.string "card")
    , ("sort", JE.string <| SearchParameters.sortOptionToString params.sort)
    , ( "filters"
      , params
        |> SearchParameters.toQueryParams
        |> UrlQueryParser.toJsonValueList
             [ "bathrooms"
             , "bedrooms"
             , "bounds"
             , "exclude_condo"
             , "exclude_house"
             , "exclude_townhouse"
             , "home_size_min"
             , "location"
             , "lot_size_min"
             , "page"
             , "price_max"
             , "price_min"
             , "year_built_min"
             ]
        |> JE.object
      )
    ]


socketResponseDecoder : JD.Value -> Result String SocketResponse
socketResponseDecoder =
  JD.decodeValue
    <| JD.map3 SocketResponse
        (JD.field "page" JD.int)
        (JD.field "total_results" JD.int)
        (JD.field "view" JD.string)


clickListeners : List (Cmd Msg)
clickListeners =
  [ Dom.addClickListener ".pagination__button--prev"
  , Dom.addClickListener ".pagination__button--next"
  , Dom.addClickListener ".elm-listing-link"
  ]


withoutModalParam : String -> String
withoutModalParam =
  UrlQueryParser.removeQueryParam Config.listingModalQueryParam
