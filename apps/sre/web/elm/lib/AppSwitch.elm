module AppSwitch exposing (..)


import Html exposing (Html)


{-| Use this module to essentially "stop" an Elm app.

    The app Model should contain an AppSwitch.
    Watch for UrlUpdate (or whatever appropriate signal) and change it to Off.

-}
type AppSwitch
  = On
  | Off


initState : AppSwitch
initState = On


subscriptions : (model -> AppSwitch) -> (model -> Sub msg) -> model -> Sub msg
subscriptions getAppSwitch subscriptions_ model =
  case getAppSwitch model of
    On ->
      subscriptions_ model

    Off ->
      Sub.none


update : (model -> AppSwitch) -> (msg -> model -> (model, Cmd msg)) -> msg -> model -> (model, Cmd msg)
update getAppSwitch update_ msg model =
  case getAppSwitch model of
    On ->
      update_ msg model

    Off ->
      model ! []


view : (model -> AppSwitch) -> (model -> Html msg) -> model -> Html msg
view getAppSwitch view_ model =
  case getAppSwitch model of
    On ->
      view_ model

    Off ->
      Html.text ""
