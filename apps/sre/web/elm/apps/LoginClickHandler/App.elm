module LoginClickHandler.App exposing (main)


import Platform
import Ports.Auth as Auth
import Ports.Dom as Dom


type Msg
  = OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)


type alias Model = ()


main : Program Never Model Msg
main =
  Platform.program
    { init =
        () !
        [ Dom.addClickListener ".elm-login-nav-item"
        ]
    , update = update
    , subscriptions = always (Dom.onClick OnClick)
    }


update : Msg -> Model -> (Model, Cmd Msg)
update (OnClick (selector, _, _)) model =
  case selector of
    ".elm-login-nav-item" ->
      ( model, Auth.showAuth0Modal Nothing )

    _ ->
      model ! []
