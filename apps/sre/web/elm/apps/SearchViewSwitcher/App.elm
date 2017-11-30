module SearchViewSwitcher.App exposing (main)


import Html exposing (Html, button, span, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Icons.Icon as Icon
import Ports.Dom as Dom


type Msg
  = SelectView Model


type Model
  = Map
  | Cards


main : Program Never Model Msg
main =
  Html.program
    { init = Cards ! []
    , update = update
    , view = view
    , subscriptions = always Sub.none
    }


update : Msg -> Model -> (Model, Cmd Msg)
update (SelectView view_) model =
  case view_ of
    Map ->
      ( Map
      , Dom.addClass (".elm-search-map-container", "search--mobile-map-visible")
      )

    Cards ->
      ( Cards
      , Dom.removeClass (".elm-search-map-container", "search--mobile-map-visible")
      )


view : Model -> Html Msg
view model =
  button
    [ type_ "button"
    , class "u-link-complex search-nav__switch-view elm-search-results-map-view"
    , onClick (toggleView model)
    ]
    [ span
        [ class "search-nav__switch-view__layout u-flex u-flexalign-items-center u-text-gray-600" ]
        [ model
          |> buttonIcon
          |> Icon.view Icon.Sm (Just "icon--gray-600")
        , model
          |> buttonText
          |> text
        ]
    ]


buttonText : Model -> String
buttonText model =
  case model of
    Cards ->
      "Map View"

    Map ->
      "Card View"


buttonIcon : Model -> Icon.Icon
buttonIcon model =
  case model of
    Cards ->
      Icon.Map

    Map ->
      Icon.Grid


toggleView : Model -> Msg
toggleView model =
  case model of
    Cards ->
      SelectView Map

    Map ->
      SelectView Cards
