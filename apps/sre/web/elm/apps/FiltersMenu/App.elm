module FiltersMenu.App exposing (main)


import Platform
import Ports.Dom as Dom


type alias Model = Bool -- Whether the menu is open
type alias Selector = String


type Msg
  = HandleClick (Selector, Dom.HtmlElement, Dom.Event)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , update = update
    , subscriptions = always (Dom.onClick HandleClick)
    }


init : (Model, Cmd Msg)
init =
  False !
  [ Dom.addClickListener ".elm-search-properties-toggle-filters"
  , Dom.addEventListener
      ( ".elm-search-properties-save-filters"
      , "click"
      , Just { stopPropagation = False, preventDefault = False }
      )
  ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model, msg) of
    (True, HandleClick _) ->
      ( False
      , Dom.removeClass ("body", "search--filters-visible")
      )

    (False, HandleClick _) ->
      ( True
      , Dom.addClass ("body", "search--filters-visible")
      )
