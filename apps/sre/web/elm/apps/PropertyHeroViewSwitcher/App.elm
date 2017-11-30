module PropertyHeroViewSwitcher.App exposing (main)


import Ports.Dom as Dom
import Ports.PubSub as PubSub


type Msg =
  OnClick (Dom.Selector, Dom.HtmlElement, Dom.Event)


main : Program Never () Msg
main =
  Platform.program
    { init = () !
        [ Dom.addClickListener ".elm-property-hero-view-photos"
        , Dom.addClickListener ".elm-property-hero-view-map"
        ]
    , update = update
    , subscriptions = always (Dom.onClick OnClick)
    }


update : Msg -> () -> ((), Cmd Msg)
update (OnClick (selector, _, _)) model =
  case selector of
    ".elm-property-hero-view-photos" ->
      () !
      [ PubSub.broadcastWithoutPayload "propertyHeroViewPhotos"
      , Dom.addClass (".elm-property-hero-nav-item-photos", "property-hero__nav__item--current")
      , Dom.removeClass (".elm-property-hero-nav-item-map", "property-hero__nav__item--current")
      ]

    ".elm-property-hero-view-map" ->
      () !
      [ PubSub.broadcastWithoutPayload "propertyHeroViewMap"
      , Dom.addClass (".elm-property-hero-nav-item-map", "property-hero__nav__item--current")
      , Dom.removeClass (".elm-property-hero-nav-item-photos", "property-hero__nav__item--current")
      ]

    _ ->
      model ! []
