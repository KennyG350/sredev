module SaveSearch.App exposing (main)

import Platform
import UrlQueryParser exposing (removeQuestionMark)
import Ports.Auth as Auth
import Ports.Dom as Dom
import Ports.Routing as Routing
import Ports.Websocket as Websocket
import Navigation exposing (Location)
import SaveSearch.Update exposing (update)
import SaveSearch.Types exposing (..)


main : Program Navigation.Location Model Msg
main =
  Platform.programWithFlags
    { init = init
    , update = update
    , subscriptions = subscriptions
    }


init : Location -> (Model, Cmd Msg)
init { search } =
  { userId = Nothing
  , searchParams = removeQuestionMark search
  } !
  [ Dom.addClickListener ".elm-save-search-button"
  , Websocket.websocketListen ("user", "save_search_success")
  , Websocket.websocketListen ("listing_list", "receive_listing_list")
  ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Websocket.websocketReceive ReceiveWebsocketMessage
    , Dom.onClick HandleClick
    , Auth.userId ReceiveUserId
    , Routing.urlUpdate UrlUpdate
    ]
