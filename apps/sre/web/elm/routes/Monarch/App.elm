module Monarch.App exposing (main)


{-| Monarch is our simple routing solution.

    It follows the "Unix philosophy" by doing only one thing:
    Launching Elm apps based on the URL path.
-}


import Html
import Navigation
import Ports.PubSub as PubSub
import Monarch.Types exposing (..)
import Monarch.Init exposing (init)
import Monarch.Update exposing (update)


main : Program Never Model Msg
main =
  Navigation.program UrlUpdate
    { init = init
    , update = update
    , view = always (Html.text "")
    , subscriptions = always <| PubSub.receiveBroadcast ReceiveBroadcast
    }
