module UserActivityWorker.App exposing (main)


{-| UserActivityWorker

    An app focused on responding to persistable activities of *Logged In Users*
    and persisting them in the database.

    Uses localStorage as a backup until confirmation is received that each
    action has been saved to the back end.

    Persists activities of anonymous users in localStorage, and saves them immediately
    to the back end if the user logs in.
-}


import Maybe
import Ports.PubSub as PubSub
import Ports.Auth as Auth
import Ports.LocalStorage as LocalStorage
import Ports.Websocket as Websocket
import Ports.Routing as Routing
import UserActivityWorker.Types exposing (..)
import UserActivityWorker.Update exposing (update, newRouteCmd)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  { userId = Nothing } !
  [ newRouteCmd
  , Websocket.websocketListen ("user", "favorite_listing_success")
  , Websocket.websocketListen ("user", "failed_saving_viewed_listing")
  ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ PubSub.receiveBroadcast ReceiveBroadcast
    , Auth.userId ReceiveUserId
    , LocalStorage.storageGetItemResponse StorageGetItemResponse
    , Websocket.websocketReceive WebsocketReceive
    , Routing.urlUpdate UrlUpdate
    ]
