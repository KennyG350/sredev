module Filters.Types exposing (..)


import Ports.Dom as Dom
import Ports.PubSub as PubSub
import SearchParameters exposing (SearchParameters)


type alias Model = SearchParameters -- Model always holds *currently applied* search parameters


type Msg
  = OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnSubmit (Dom.Selector, Dom.JsonPayload)
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | SetFiltersFromSearchParameters SearchParameters
