module MultiUnitList.Update exposing (update)


import Route exposing (Route(..))
import Json.Encode as JE
import Json.Decode as JD
import Maybe exposing (withDefault, andThen)
import UrlQueryParser
import Ports.PubSub as PubSub
import Ports.Dom as Dom
import Ports.GoogleMaps as GoogleMaps exposing (LatLng)
import Ports.Websocket as Websocket
import SearchParameters exposing (SearchParameters)
import DecodeHelper
import MapPosition exposing (MapPosition(..))
import MultiUnitList.Types exposing (..)
import MultiUnitList.Config exposing (..)


type alias MultiUnitSearch =
  { latLng : LatLng
  , searchParameters : String -- Represented as a query string for convenience
  }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HandleClick (".elm-search-property-contents .elm-listing-link", { pathname }, _) ->
      case pathname of
        Just pathname_ ->
          case Route.fromPathname pathname_ of
            Just (ListingDetails listingUrl) ->
              model !
              [ Dom.innerHtml (containerSelector, "")
              , PubSub.broadcast ("listingClicked", JE.string listingUrl)
              ]

            _ ->
              model ! []

        _ ->
          model ! []

    HandleClick (".elm-search-property-close", _, _) ->
      model !
      [ Dom.innerHtml (containerSelector, "")
      , Dom.removeClass (".elm-search-property", "search__property--visible")
      , Dom.removeCssProperty (".elm-listing-expand", "display")
      ]

    ReceiveWebsocketMessage ("listing_list:multi_unit_modal", "receive_listing_list", payload) ->
      case DecodeHelper.decodeListingListResponse payload of
        Ok response ->
          model !
          [ Dom.innerHtml (containerSelector, response.view)
          , Dom.setCssProperty (".elm-search-property-contents .search__results__pagination", "display", "none")
          ]

        Err error ->
          model ! []

    ReceiveBroadcast ("openMultiUnitModal", payload) ->
      case JD.decodeValue multiUnitSearchDecoder payload of
        Ok { latLng, searchParameters } ->
          model !
          [ Dom.addClass (".elm-search-property", "search__property--visible")
          , Dom.setCssProperty (".elm-listing-expand", "display", "none")
          , Websocket.websocketSend
              ( websocketTopic
              , websocketEventRequest
              , listingListRequest latLng (SearchParameters.fromQueryParams searchParameters)
              )
          ]

        Err _ ->
          model ! []

    InnerHtmlReplaced ".elm-search-property-contents" ->
      model ! [ Dom.addClickListener clickTargetSelector ] -- "Re-add" click listener to newly rendered DOM nodes

    _ ->
      model ! []


listingListRequest : GoogleMaps.LatLng -> SearchParameters -> JE.Value
listingListRequest latLng searchParameters =
  JE.object
    [ ("page", JE.string "1")
    , ( "filters"
      , searchParameters
        |> SearchParameters.toQueryParams
        |> UrlQueryParser.toJsonValueList
             [ "bathrooms"
             , "bedrooms"
             , "exclude_condo"
             , "exclude_house"
             , "exclude_townhouse"
             , "home_size_min"
             , "lot_size_min"
             , "price_max"
             , "price_min"
             , "year_built_min"
             ]
        |> \jsonValues ->
             ("bounds", JE.string <| MapPosition.toString_ (Center latLng)) :: jsonValues
        |> JE.object
      )
    ]


multiUnitSearchDecoder : JD.Decoder MultiUnitSearch
multiUnitSearchDecoder =
  JD.map2 MultiUnitSearch
    (JD.field "propertyLatLng" GoogleMaps.latLngDecoder)
    (JD.field "currentSearchParameters" JD.string)
