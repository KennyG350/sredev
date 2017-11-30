module Filters.PropertyType.App exposing (main)


import Json.Encode as JE
import Ports.Dom as Dom


type Msg = OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)


buttonSelector : String
buttonSelector = ".elm-filters-property-type-select-all"


checkboxSelectors : List String
checkboxSelectors =
  [ ".elm-filters-property-type-house"
  , ".elm-filters-property-type-townhouse"
  , ".elm-filters-property-type-condo"
  ]


main : Program Never () Msg
main =
  Platform.program
    { init = ((), Dom.addClickListener buttonSelector)
    , subscriptions = always (Dom.onClick OnClick)
    , update = update
    }


update : Msg -> () -> ((), Cmd Msg)
update (OnClick _) _ =
  checkboxSelectors
  |> List.map checkCmd
  |> \cmds ->
       () ! cmds


checkCmd : String -> Cmd Msg
checkCmd selector =
  Dom.setProperty (selector, "checked", JE.bool True)
