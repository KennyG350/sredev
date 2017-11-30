module RouteHelper exposing (..)


import Navigation
import Json.Encode
import Ports.PubSub as PubSub


{-| Change the URL in the address bar and add entry to the history stack.
-}
newUrl : String -> Cmd msg
newUrl url =
  PubSub.broadcast ("monarchNewUrl", Json.Encode.string url)


{-| Change the URL in the address bar and replace the current "history" entry.
-}
modifyUrl : String -> Cmd msg
modifyUrl url =
  PubSub.broadcast ("monarchModifyUrl", Json.Encode.string url)


{-| Go back in history; equivalent to the user hitting the back button.
-}
back : Cmd msg
back =
  PubSub.broadcastWithoutPayload "monarchBack"


{-| Reload the browser.
-}
reload : Cmd msg
reload =
  PubSub.broadcastWithoutPayload "monarchReload"


urlFromLocation : Navigation.Location -> String
urlFromLocation location =
  location.pathname ++ location.search
