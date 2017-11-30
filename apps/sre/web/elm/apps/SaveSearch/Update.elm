module SaveSearch.Update exposing (update)

import Json.Decode as JD
import Json.Encode as JE
import UrlQueryParser exposing (removeQuestionMark)
import Ports.Auth as Auth
import Ports.Dom as Dom
import Ports.Websocket as Websocket
import SaveSearch.Types exposing(..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlUpdate { search } ->
      { model | searchParams = removeQuestionMark search } ! []

    HandleClick (".elm-save-search-button", _, _) ->
      case model.userId of
        Just userId ->
          model !
            [ Websocket.websocketSend
                ( "user"
                , "save_search"
                , encodeMessage model.searchParams
                )
            ]
        Nothing ->
          model ! [ Auth.showAuth0Modal Nothing ]

    ReceiveUserId userId ->
      { model | userId = userId } ! []

    ReceiveWebsocketMessage ("user", "save_search_success", payload) ->
      case socketResponseDecoder payload of
        Ok response ->
          model !
            [ Dom.addClass (".search-nav__save-search", "search-nav__save-search--saved")
            , Dom.innerHtml (".search-nav__save-search__save-label span", response.searchName)
            ]

        Err error ->
          model ! []

    ReceiveWebsocketMessage ("listing_list", "receive_listing_list", payload) ->
      case listingResponseDecoder payload of
        Ok { savedSearch } ->
          case savedSearch of
            Nothing ->
              model !
                [ Dom.removeClass (".search-nav__save-search", "search-nav__save-search--saved")
                ]

            Just { name } ->
              model !
                [ Dom.addClass (".search-nav__save-search", "search-nav__save-search--saved")
                , Dom.innerHtml (".search-nav__save-search__save-label span", name)
                ]
        _ ->
          model ! []
    _ ->
      model ! []



encodeMessage : String -> JE.Value
encodeMessage queryString =
  [ ("search_params", JE.string queryString)
  ]
  |> JE.object



socketResponseDecoder : JD.Value -> Result String SocketResponse
socketResponseDecoder =
  JD.decodeValue
    <| JD.map SocketResponse
        (JD.field "search_name" JD.string)


listingResponseDecoder : JD.Value -> Result String ListingListResponse
listingResponseDecoder =
  JD.decodeValue
    <| JD.map ListingListResponse
        (JD.field "saved_search" (JD.nullable savedSearchDecoder))


savedSearchDecoder : JD.Decoder SavedSearch
savedSearchDecoder =
  JD.map2 SavedSearch
    (JD.field "name" JD.string)
    (JD.field "id" JD.int)
