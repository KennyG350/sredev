module PropertyHeroImageSlider.Update exposing (update)


import Ports.Dom as Dom
import PropertyHeroImageSlider.Types exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    QuerySelectorResponse (_, { data }) ->
      case Dom.dataAttribute data "photoCount" of
        Just photoCountString ->
          case String.toInt photoCountString of
            Ok photoCount ->
              { model | photoCount = Just photoCount } ! []

            Err _ ->
              model ! []

        Nothing ->
          model ! []

    OnClick (selector, _, _) ->
      case selector of
        ".elm-image-slider-prev" ->
          update DecrementPhoto model

        ".elm-image-slider-next" ->
          update IncrementPhoto model

        _ ->
          model ! []


    KeyDown keyCode ->
      case keyCodeToKey keyCode of
        Just LeftArrow ->
          update DecrementPhoto model

        Just RightArrow ->
          update IncrementPhoto model

        Nothing ->
          model ! []

    IncrementPhoto ->
      case model.photoCount of
        Just photoCount ->
          if model.currentPhoto >= photoCount - 1 then
            scrollToPhotoModelCmd { model | currentPhoto = 0 }

          else
            scrollToPhotoModelCmd { model | currentPhoto = model.currentPhoto + 1 }

        Nothing ->
          model ! []

    DecrementPhoto ->
      case model.photoCount of
        Just photoCount ->
          if model.currentPhoto < 1 then
            scrollToPhotoModelCmd { model | currentPhoto = photoCount - 1 }

          else
            scrollToPhotoModelCmd { model | currentPhoto = model.currentPhoto - 1 }

        Nothing ->
          model ! []

    OnFocusTextInput _ ->
      { model | textInputFocusCounter = model.textInputFocusCounter + 1 } ! []

    OnBlurTextInput _ ->
      { model | textInputFocusCounter = model.textInputFocusCounter - 1 } ! []

    OnTouchStart (_, _, { touchClientX }) ->
      { model | touchStartX = touchClientX } ! []

    OnTouchMove (_, _, { touchClientX }) ->
      case (model.touchStartX, touchClientX) of
        (Just touchStartX, Just touchMoveX) ->
          if abs (touchMoveX - touchStartX) > 20 then
            if touchMoveX > touchStartX then
              update DecrementPhoto { model | touchStartX = Nothing }

            else
              update IncrementPhoto { model | touchStartX = Nothing }

          else
            model ! []

        _ ->
          model ! []


scrollToPhotoModelCmd : Model -> (Model, Cmd Msg)
scrollToPhotoModelCmd model =
  model !
  [ Dom.innerHtml (".elm-image-slider-current-photo", toString <| model.currentPhoto + 1)
  , Dom.setCssProperty
      ( ".elm-image-slider-transform-container"
      , "transform"
      , "translateX(" ++ (toString <| model.currentPhoto * -100) ++ "%)"
      )
  ]
