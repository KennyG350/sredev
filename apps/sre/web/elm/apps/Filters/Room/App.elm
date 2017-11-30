module Filters.Room.App exposing (main)


import Json.Encode as JE
import Ports.Dom as Dom


type Msg
  = OnChange (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)


type alias Flags =
  { containerSelector : String
  }


type alias Model = Flags


main : Program Flags Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : Flags -> (Model, Cmd Msg)
init flags =
  ( flags
  , Dom.addClickListener (flags.containerSelector ++ " .elm-filters-rooms-label")
  )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onClick OnClick
    ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OnClick (selector, { for }, _) ->
      case (for, selector == (model.containerSelector ++ " .elm-filters-rooms-label")) of
        (Just for_, True) ->
          model !
          [ Dom.setProperty ("#" ++ for_, "checked", JE.bool True)
          , Dom.removeClass
              ( model.containerSelector
                ++ " .elm-filters-rooms-label:not(.elm-filters-rooms-label-"
                ++ for_
                ++ ")"
              , "segmented-control__segment--selected"
              )
          , Dom.addClass
              ( model.containerSelector ++ " .elm-filters-rooms-label-" ++ for_
              , "segmented-control__segment--selected"
              )
          ]

        _ ->
          model ! []

    _ ->
      model ! []
