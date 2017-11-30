module Filters.PriceRange.App exposing (main)


import Ports.PubSub as PubSub
import Ports.Dom as Dom
import Filters.PriceRange.Types exposing (..)
import Filters.PriceRange.Types.PriceLimit exposing (PriceLimit(..))
import Filters.PriceRange.Update exposing (update)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  let
    (model, cmd) = update ResetPriceRange (Model NoLimit NoLimit)
  in
    model !
    [ Dom.addEventListener (".elm-filters-price-minimum", "focus", Nothing)
    , Dom.addEventListener (".elm-filters-price-maximum", "focus", Nothing)
    , Dom.addEventListener (".elm-filters-price-minimum", "blur", Nothing)
    , Dom.addEventListener (".elm-filters-price-maximum", "blur", Nothing)
    , cmd
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ PubSub.receiveBroadcast ReceiveBroadcast
    , Dom.onFocus OnFocus
    , Dom.onBlur OnBlur
    ]
