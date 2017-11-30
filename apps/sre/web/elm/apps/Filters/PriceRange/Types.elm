module Filters.PriceRange.Types exposing (..)


import Ports.PubSub as PubSub
import Ports.Dom as Dom
import Filters.PriceRange.Types.PriceLimit exposing (PriceLimit)


type alias Model =
  { minimum : PriceLimit
  , maximum : PriceLimit
  }

type Msg
  = ResetPriceRange
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)
  | OnFocus (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnBlur (Dom.Selector, Dom.HtmlElement, Dom.Event)
