module ListingDetailsModal.Update exposing (update)


import Result
import Regex exposing (replace, HowMany(..), regex)
import Json.Encode as JE
import Json.Decode as JD
import Ports.Websocket as Websocket
import Ports.Dom as Dom
import Ports.Analytics as Analytics
import Ports.GoogleMaps as GoogleMaps
import Ports.PubSub as PubSub
import Config
import Route exposing (Route(..))
import ListingDetailsModal.Types exposing (..)


type alias HtmlContents =
  { title : String
  , url : String
  , view : String
  }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveBroadcast ("propertyMarkerClicked", payload) ->
      case JD.decodeValue GoogleMaps.propertyMarkerDecoder payload of
        Ok { url } ->
          update (LoadModal url) model

        _ ->
          model ! []

    ReceiveBroadcast ("listingClicked", payload) ->
      case JD.decodeValue JD.string payload of
        Ok url ->
          update (LoadModal url) model

        _ ->
          model ! []

    LoadModal url ->
      model !
      [ Dom.removeClass ( ".elm-search-property-loading", "u-hidden" )
      , Websocket.websocketSend <| (,,) "listing_details" "request_listing_details" <| listingDetailsRequest url
      , Websocket.websocketSend <| (,,) "user" "viewed_listing" <| listingDetailsRequest url
      ]

    CloseModal ->
      { model | view = Nothing } !
      [ Dom.innerHtml ( ".elm-listing-phone-number", "" )
      , Dom.innerHtml ( ".elm-search-property-contents", "")
      , Dom.removeClass ( ".elm-search-property", "search__property--visible" )
      , Dom.removeClass ( "body", "noscroll" )
      ]

    HandleClick (".elm-search-property-close", _, _) ->
      let
        (model_, cmd) = update CloseModal model
      in
        model !
        [ cmd
        , PubSub.broadcastWithoutPayload "listingDetailsModalClosed"
        ]

    QuerySelectorResponse (".elm-listing-phone-number", { innerHtml }) ->
      case innerHtml of
        Nothing ->
          model ! []

        Just rawHtml ->
          let
            phoneNumber = rawHtml
            phoneNumberWithoutPunctuation = replace All (regex "\\D") (\_ -> "") phoneNumber
          in
            model !
              [ Dom.innerHtml ( ".elm-header-phone-number", phoneNumber ++ " Call for more info" )
              , Dom.setProperty ( ".elm-header-phone-number", "href", JE.string <| "tel:" ++ phoneNumberWithoutPunctuation)
              ]

    ReceiveWebsocketMessage ("listing_details", "receive_listing_details", payload)  ->
      case htmlDecoder payload of
        Ok { title, url, view } ->
          { model | view = Just view } !
          -- Order matters! These commands seem synchronous, although technically there's no
          -- guaranteed order from the Elm scheduler.
          [ Dom.innerHtml ( ".elm-search-property-contents", view )
          , Dom.addClass ( ".elm-search-property", "search__property--visible" )
          , Dom.addClass ( ".elm-search-property-loading", "u-hidden" )
          , Dom.setProperty
              ( ".elm-listing-expand"
              , "href"
              , JE.string <| "/properties/" ++ url
              )
          , Analytics.gaPageView ( model.location.pathname, title )
          , Dom.querySelector ".elm-listing-phone-number"
          , Dom.addClass ( "body", "noscroll" )
          , PubSub.broadcast ("listingDetailsModalOpened", JE.string url)
          ]

        Err error ->
          model ! []

    InnerHtmlReplaced ".elm-search-property-contents" ->
      case model.view of
        Just _ ->
          (model, PubSub.broadcastWithoutPayload Config.launchListingDetailsModalMessage)

        Nothing ->
          model ! []

    UrlUpdate location ->
      let
        model_ = { model | location = location }
      in
        case (Route.fromLocation location, model_.view) of
          (Just (Search Nothing), Just _) ->
            update CloseModal model_

          (Just (Search (Just listingUrlSlug)), Nothing) ->
            update (LoadModal listingUrlSlug) model_

          _ ->
            model_ ! []

    _ ->
      model ! []


listingDetailsRequest : String -> JE.Value
listingDetailsRequest url =
  JE.object
    [ ( "url", JE.string url )
    , ( "mobile", JE.bool False ) -- TODO: Either re-wire up a mobile flag when mobile layout is back, or remove this
    ]


htmlDecoder : JD.Value -> Result String HtmlContents
htmlDecoder =
  JD.decodeValue
    <| JD.map3 HtmlContents
        (JD.field "title" JD.string)
        (JD.field "url" JD.string)
        (JD.field "view" JD.string)
