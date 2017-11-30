module PreventDoubleUrlEncoding.App exposing (main)


{-| Intended to run immediately when the user enters the site.

    Checks if the URL contains any double- or triple- (etc) encoded
    parameters. If so, immediately updates the URL to the completely decoded version.

    Double encoded values can break the search map and possibly other Elm apps.
-}


import Http exposing (decodeUri)
import Json.Encode as JE
import RouteHelper
import UrlQueryParser
import Ports.Routing as Routing
import Ports.PubSub as PubSub


type alias Model = ()


type Msg
  = UrlUpdate Routing.Location


main : Program Routing.Location Model Msg
main =
  Platform.programWithFlags
    { init = init
    , subscriptions = always (Sub.none)
    , update = \_ _ -> () ! []
    }


init : Routing.Location -> (Model, Cmd Msg)
init location =
  ( ()
  , urlEncodingCmd location
  )


urlEncodingCmd : Routing.Location -> Cmd Msg
urlEncodingCmd { pathname, search } =
  case decodeUri search of
    Just decodedUri ->
      case decodeUri decodedUri of
        Just doubleDecodedUri ->
          if decodedUri == doubleDecodedUri then
            Cmd.none

          else
            search
            |> UrlQueryParser.decodeUriCompletely
            |> \decodedSearch ->
                 Cmd.batch
                   [ RouteHelper.modifyUrl (String.append pathname decodedSearch)
                   , PubSub.broadcast
                       ( "repairedMultipleUrlEncoding"
                       , JE.string decodedSearch
                       )
                   ]

        Nothing ->
          Cmd.none

    Nothing ->
      Cmd.none
