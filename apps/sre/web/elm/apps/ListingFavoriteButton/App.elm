module ListingFavoriteButton.App exposing (main)


import Maybe
import Ports.Auth as Auth
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import ListingFavoriteButton.Types exposing (..)
import ListingFavoriteButton.Update exposing (update, addEventListenerCmd)


main : Program Flags Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : Flags -> (Model, Cmd Msg)
init { containerSelector } =
  ( { userId = Nothing
    , containerSelector = containerSelector
    }
  , addEventListenerCmd containerSelector
  )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onClick OnClick
    , Auth.userId ReceiveUserId
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]
