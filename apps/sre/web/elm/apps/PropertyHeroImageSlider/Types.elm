module PropertyHeroImageSlider.Types exposing (..)


import Keyboard
import Ports.Dom as Dom


type alias Model =
  { currentPhoto : Int -- Zero-indexed (0 == the first photo)
  , photoCount : Maybe Int
  , textInputFocusCounter : Int -- When >0, the user is focused on a text input
  , touchStartX : Maybe Float
  }


type Msg
  = OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | QuerySelectorResponse (Dom.Selector, Dom.HtmlElement)
  | KeyDown Keyboard.KeyCode
  | IncrementPhoto
  | DecrementPhoto
  | OnFocusTextInput (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnBlurTextInput (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnTouchStart (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnTouchMove (Dom.Selector, Dom.HtmlElement, Dom.Event)


type Key
  = LeftArrow
  | RightArrow


keyCodeToKey : Int -> Maybe Key
keyCodeToKey keyCode =
  case keyCode of
    37 ->
      Just LeftArrow

    39 ->
      Just RightArrow

    _ ->
      Nothing
