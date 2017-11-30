module HandleLoginError.App exposing (main)


import Ports.Routing as Routing
import Ports.Auth as Auth
import UrlQueryParser
import Config


main : Program Routing.Location () msg
main =
  Platform.programWithFlags
    { init = init
    , update = \_ _ -> () ! []
    , subscriptions = always Sub.none
    }


init : Routing.Location -> ((), Cmd msg)
init { search } =
  case UrlQueryParser.getQueryParam search "login_error" of
    Just "true" ->
      () !
      [ Auth.showAuth0Modal <|
          Just
            { isError = True
            , message = Config.loginErrorMessage
            }
      ]

    _ ->
      () ! []
