module BuyCalculator.ListingSearch.App exposing (main)


import Debounce
import Ports.PubSub as PubSub
import Ports.Websocket as Websocket
import Ports.Dom as Dom
import Config
import BuyCalculator.ListingSearch.Types exposing (..)
import BuyCalculator.ListingSearch.Update exposing (update)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  { bounds = Nothing
  , latitude = Nothing
  , longitude = Nothing
  , location = Nothing
  , throttleState = Debounce.init
  , lastSearch = Nothing
  , price = Config.buyCalculatorInitialPrice
  } !
  [ Websocket.websocketListen ("listing_list", "receive_listing_list")
  , Dom.querySelector Config.locationBoundsMetaTagSelector
  , Dom.querySelector Config.locationMetaTagSelector
  ]


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ PubSub.receiveBroadcast ReceiveBroadcast
    , Websocket.websocketReceive WebsocketReceive
    , Dom.querySelectorResponse QuerySelectorResponse
    ]
