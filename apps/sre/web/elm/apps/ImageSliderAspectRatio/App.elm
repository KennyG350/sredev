module ImageSliderAspectRatio.App exposing (main)


import Time
import Debounce exposing (Debounce)
import Ports.Dom as Dom
import Config


type alias Model =
  { resizeThrottleState : Debounce ()
  }


type Msg
  = OnResize (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | QuerySelectorResponse (Dom.Selector, Dom.HtmlElement)
  | ThrottleResize Debounce.Msg


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  { resizeThrottleState = Debounce.init } !
  [ Dom.querySelector Config.imageSlider16By9ContainerSelector
  , Dom.addEventListener ("window", "resize", Nothing)
  ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onResize OnResize
    , Dom.querySelectorResponse QuerySelectorResponse
    ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OnResize _ ->
      let
        (throttleState, cmd) = Debounce.push resizeDebounceConfig () model.resizeThrottleState
      in
        ({ model | resizeThrottleState = throttleState }, cmd)

    QuerySelectorResponse (_, htmlElement) ->
      case htmlElement.clientWidth of
        Just clientWidth ->
          ( model
          , setItemHeightsCmd clientWidth
          )

        Nothing ->
          model ! []

    ThrottleResize throttleMsg ->
      let
        (throttleState, cmd) =
          Debounce.update resizeDebounceConfig
            (Debounce.takeLast <| always <| Dom.querySelector Config.imageSlider16By9ContainerSelector)
            throttleMsg
            model.resizeThrottleState
      in
        ({ model | resizeThrottleState = throttleState }, cmd)


setItemHeightsCmd : Int -> Cmd Msg
setItemHeightsCmd containerWidth =
  Dom.setCssProperty
    ( Config.imageSliderImageSelector
    , "height"
    , containerWidth
      |> toFloat
      |> (*) Config.image16By9Multiplier
      |> round
      |> toString
      |> (flip String.append) "px"
    )


resizeDebounceConfig : Debounce.Config Msg
resizeDebounceConfig =
  { strategy = Debounce.soon (350 * Time.millisecond)
  , transform = ThrottleResize
  }
