module DisplayContactForm.App exposing (..)

import Ports.Dom as Dom

type alias Selector = String
type alias Model =
  { isShowing : Bool
  }


type Msg
  = HandleClick (Selector, Dom.HtmlElement, Dom.Event)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    }


init : (Model, Cmd Msg)
init =
  { isShowing = False }
  ! [ Dom.addClickListener ".elm-contact-form-btn"
    ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HandleClick _ ->
      let
        buttonText =
          if model.isShowing then
            "Contact"
          else
            "Cancel"
      in
        { model | isShowing = not model.isShowing }
        ! [ Dom.toggleClass (".property-aside", "property-aside--mobile-contact-form-visible")
          , Dom.innerHtml (".elm-contact-form-btn span", buttonText)
          ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onClick HandleClick
    ]
