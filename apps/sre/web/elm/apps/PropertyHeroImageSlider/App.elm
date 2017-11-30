module PropertyHeroImageSlider.App exposing (..)


import Keyboard
import Ports.Dom as Dom
import PropertyHeroImageSlider.Types exposing (..)
import PropertyHeroImageSlider.Update exposing (update)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    }


init : (Model, Cmd Msg)
init =
  { currentPhoto = 0
  , photoCount = Nothing
  , textInputFocusCounter = 0
  , touchStartX = Nothing
  } !
  [ Dom.addClickListener ".elm-image-slider-prev"
  , Dom.addClickListener ".elm-image-slider-next"
  , Dom.querySelector ".elm-image-slider-photo-count"
  , Dom.addEventListener ("input[type=text],input[type=email]", "focus", Nothing)
  , Dom.addEventListener ("input[type=text],input[type=email]", "blur", Nothing)
  , Dom.addEventListener (".elm-image-slider-transform-container", "touchstart", touchListenerOptions)
  , Dom.addEventListener (".elm-image-slider-transform-container", "touchmove", touchListenerOptions)
  ]


subscriptions : Model -> Sub Msg
subscriptions { photoCount, textInputFocusCounter } =
  Sub.batch
    [ Dom.onClick OnClick
    , Dom.onFocus OnFocusTextInput
    , Dom.onBlur OnBlurTextInput
    , Dom.onTouchstart OnTouchStart
    , Dom.onTouchmove OnTouchMove
    , case photoCount of
        Just _ ->
          case textInputFocusCounter of
            0 ->
              Keyboard.downs KeyDown

            _ ->
              Sub.none

        Nothing ->
          Dom.querySelectorResponse QuerySelectorResponse
    ]


touchListenerOptions : Maybe Dom.EventListenerOptions
touchListenerOptions =
  Just
    { stopPropagation = False
    , preventDefault = False
    }
