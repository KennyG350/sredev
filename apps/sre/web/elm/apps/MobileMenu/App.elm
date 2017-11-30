module MobileMenu.App exposing (main)


import Platform
import Ports.Dom as Dom


type alias Model =
  { visibility : Visibility
  }


type Msg =
  OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)


type Visibility
  = Visible
  | Hidden


main : Program Never Model Msg
main =
  Platform.program
    { init = (Model Visible, Dom.addClickListener ".elm-mobile-main-nav-toggle")
    , subscriptions = always <| Dom.onClick OnClick
    , update = update
    }


update : Msg -> Model -> (Model, Cmd Msg)
update (OnClick _) { visibility } =
  case visibility of
    Visible ->
      Model Hidden !
      [ Dom.addClass (".elm-mobile-header-container", "header--mobile-nav-visible")
      , Dom.addClass ("body", "noscroll")
      ]

    Hidden ->
      Model Visible !
      [ Dom.removeClass (".elm-mobile-header-container", "header--mobile-nav-visible")
      , Dom.removeClass ("body", "noscroll")
      ]
