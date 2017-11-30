module HandleInviteToken.App exposing (main)


import Platform
import UrlQueryParser
import Ports.Auth as Auth
import Ports.Routing as Routing


main : Program Routing.Location () msg
main =
  Platform.programWithFlags
    { init = init
    , update = \_ _ -> () ! []
    , subscriptions = always Sub.none
    }


init : Routing.Location -> ((), Cmd msg)
init { search } =
  case UrlQueryParser.getQueryParam search "token" of
    Just token ->
      () !
      [ Auth.showAuth0Modal Nothing
      ]

    Nothing ->
      () ! []
