module WalkScore.App exposing (main)


import Platform
import Ports.Dom as Dom
import Ports.WalkScore as WalkScore


type alias Model = ()
type alias Selector = String


type Msg =
  QuerySelectorResponse (Selector, Dom.HtmlElement)


main : Program Never Model Msg
main =
  Platform.program
    { init = () ! [ Dom.querySelector ".elm-walk-score" ]
    , update = update
    , subscriptions = always (Dom.querySelectorResponse QuerySelectorResponse)
    }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    QuerySelectorResponse (".elm-walk-score", { data }) ->
      case (Dom.dataAttribute data "lat", Dom.dataAttribute data "lon") of
        (Just lat, Just lon) ->
          ( model
          , WalkScore.showWalkScoreTile (lat, lon)
          )

        _ ->
          model ! []

    _ ->
      model ! []
