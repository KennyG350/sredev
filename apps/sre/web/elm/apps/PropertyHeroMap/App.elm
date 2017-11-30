module PropertyHeroMap.App exposing (main)


import Result exposing (toMaybe)
import Maybe exposing (andThen)
import AppSwitch exposing (AppSwitch)
import Route exposing (Route(..))
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import Ports.Routing as Routing
import Ports.GoogleMaps as GoogleMaps
import Ports.GoogleMaps.ControlPosition exposing (ControlPosition(..), toMaybeString)
import Config


type alias Price = Float


type alias Model =
  { latLng : Maybe GoogleMaps.LatLng
  , price : Maybe Price
  , mapCreated : Bool
  , appSwitch : AppSwitch
  }


type Msg
  = QuerySelectorResponse (Dom.Selector, Dom.HtmlElement)
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | CreateMap GoogleMaps.LatLng -- LatLng is where to center the map
  | CreateMapFinished GoogleMaps.Selector
  | ShowMap GoogleMaps.LatLng -- Re-center map on LatLng when showing
  | HideMap
  | UrlUpdate Routing.Location


defaultZoom : Int
defaultZoom = 18


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = AppSwitch.subscriptions .appSwitch subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  ( { latLng = Nothing
    , price = Nothing
    , mapCreated = False
    , appSwitch = AppSwitch.On
    }
  , Dom.querySelector ".elm-property-hero-map-container"
  )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ PubSub.receiveBroadcast ReceiveBroadcast
    , GoogleMaps.createMapFinished CreateMapFinished
    , Dom.querySelectorResponse QuerySelectorResponse
    , Routing.urlUpdate UrlUpdate
    ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    QuerySelectorResponse (".elm-property-hero-map-container", { data }) ->
      let
        data_ =
          (Dom.dataAttribute data) >> (andThen (String.toFloat >> Result.toMaybe))
      in
        case (data_ "lat", data_ "lon", data_ "price") of
          (Just lat, Just lng, Just price) ->
            { model
            | price = Just price
            , latLng = Just (GoogleMaps.LatLng lat lng)
            } ! []

          _ ->
            model ! []

    ReceiveBroadcast ("propertyHeroViewMap", _) ->
      case model.latLng of
        Just latLng ->
          if model.mapCreated then
            update (ShowMap latLng) model

          else
            update (CreateMap latLng) model

        Nothing ->
          model ! []

    CreateMap latLng ->
      ( model
      , GoogleMaps.createMap
          ( ".elm-property-hero-map-container"
          , { center = Just latLng
            , disableDefaultUI = Just False
            , mapTypeControlPosition = toMaybeString TOP_RIGHT
            , mapTypeId = Just "SATELLITE"
            , maxZoom = Nothing
            , minZoom = Nothing
            , rotateControlPosition = toMaybeString TOP_RIGHT
            , scrollWheel = Nothing
            , signInControl = Just False
            , streetViewControlPosition = toMaybeString TOP_RIGHT
            , styles = Config.defaultMapStyles
            , zoom = Just defaultZoom
            , zoomControlPosition = toMaybeString TOP_RIGHT
            }
          )
      )

    CreateMapFinished ".elm-property-hero-map-container" ->
      let
        model_ = { model | mapCreated = True }
      in
        case (model.latLng, model.price) of
          (Just latLng, Just price) ->
            let
              (_, showMapCmd) = update (ShowMap latLng) model
            in
              model_ !
              [ GoogleMaps.addPropertyMarkers
                  ( ".elm-property-hero-map-container"
                  , [ GoogleMaps.PropertyMarker latLng price "" ]
                  )
              , showMapCmd
              ]

          _ ->
            model_ ! []

    ShowMap latLng ->
      model !
      [ Dom.addClass (".elm-property-hero-map-overlay", "map-overlay--visible")
      , GoogleMaps.setCenter (".elm-property-hero-map-container", latLng)
      , GoogleMaps.setZoom (".elm-property-hero-map-container", defaultZoom)
      ]

    ReceiveBroadcast ("propertyHeroViewPhotos", _) ->
      update HideMap model

    HideMap ->
      ( model
      , Dom.removeClass (".elm-property-hero-map-overlay", "map-overlay--visible")
      )

    UrlUpdate location ->
      if isListingDetailsModalRoute location then
        model ! []

      else -- Shut off this app when navigating away from modal
        { model | appSwitch = AppSwitch.Off } ! []

    _ ->
      model ! []


isListingDetailsModalRoute : Routing.Location -> Bool
isListingDetailsModalRoute =
  Route.fromLocation
  >> Maybe.map Route.isListingDetailsModal
  >> Maybe.withDefault False
