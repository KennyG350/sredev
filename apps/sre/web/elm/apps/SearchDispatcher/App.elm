module SearchDispatcher.App exposing (main)


import Ports.PubSub as PubSub
import Ports.Routing as Routing
import Route
import SearchParameters
import SearchDispatcher.Update exposing (update)
import SearchDispatcher.Types exposing (..)


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
    searchParameters = SearchParameters.fromQueryParams location.search
  in
    ( { searchParameters = searchParameters
      , route = Route.fromLocation location
      }
    , PubSub.broadcast ("searchParametersInitialized", SearchParameters.toJson searchParameters)
    )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ PubSub.receiveBroadcast ReceiveBroadcast
    , Routing.urlUpdate UrlUpdate
    ]
