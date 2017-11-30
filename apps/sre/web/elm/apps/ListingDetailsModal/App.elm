module ListingDetailsModal.App exposing (main)


import Ports.Dom as Dom
import Ports.Websocket as Websocket
import Ports.PubSub as PubSub
import Ports.Routing as Routing
import ListingDetailsModal.Types exposing (..)
import ListingDetailsModal.Update as Update exposing (update)


main : Program Routing.Location Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : Routing.Location -> (Model, Cmd Msg)
init location =
  let
    model =
      { location = location
      , view = Nothing
      }

    (model_, cmd) =
      update (UrlUpdate model.location) model
  in
    model_ !
    [ Websocket.websocketListen ("listing_details", "receive_listing_details")
    , Dom.addClickListener ".elm-search-property-close"
    , cmd
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onClick HandleClick
    , Dom.querySelectorResponse QuerySelectorResponse
    , Dom.innerHtmlReplaced InnerHtmlReplaced
    , Websocket.websocketReceive ReceiveWebsocketMessage
    , PubSub.receiveBroadcast ReceiveBroadcast
    , Routing.urlUpdate UrlUpdate
    ]
