module Monarch.Update exposing (update, locationMatchesRegex, appCmd, routeLogCmd)


import Dict exposing (Dict)
import Regex exposing (regex)
import Json.Decode as JD
import Json.Encode as JE
import Http exposing (decodeUri)
import Navigation exposing (Location)
import Ports.Routing as Routing
import Monarch.Ports as Ports
import Monarch.Types exposing (..)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveBroadcast ("monarchNewUrl", newUrl) ->
      let
        nextUrl =
          newUrl
          |> JD.decodeValue JD.string
          |> Result.toMaybe

        previousUrl = decodeUri (model.location.pathname ++ model.location.search)
      in
        if nextUrl == previousUrl then
          model ! []

        else
          ( model
          , stringValueToCmd Navigation.newUrl newUrl
          )

    ReceiveBroadcast ("monarchModifyUrl", modifiedUrl) ->
      ( model
      , stringValueToCmd Navigation.modifyUrl modifiedUrl
      )

    ReceiveBroadcast ("monarchBack", _) ->
      ( model
      , Navigation.back 1 -- Navigation seems kind of buggy with this. Use carefully.
      )

    ReceiveBroadcast ("monarchReload", _) ->
      ( model
      , Ports.refreshBrowser ()
      )

    UrlUpdate location -> -- Launch routes with OnUrl strategy
      let
        routeUrls =
          model.routesOnUrl
          |> Dict.keys
          |> List.filter (locationMatchesRegex location)

        newPathname = model.location.pathname /= location.pathname
        routeFoundExpectingRefresh = List.any (locationMatchesRegex location) model.newPageLoadWithUrlRoutes
        reloadPage = newPathname && routeFoundExpectingRefresh
      in
        { model | location = location } !
        [ Routing.broadcastUrlUpdate location
        , if reloadPage then Ports.refreshBrowser () else Cmd.none
        , routeUrls
            |> List.map ((flip Dict.get) model.routesOnUrl)
            |> List.map (Maybe.withDefault [])
            |> List.concat
            |> List.map appCmd
            |> Cmd.batch
        , routeUrls
            |> List.map OnUrl
            |> List.map routeLogCmd
            |> Cmd.batch
        ]

    ReceiveBroadcast (message, _) -> -- Launch routes with OnBroadcast strategy
      if Dict.member message model.routesOnBroadcast then
        model.routesOnBroadcast
        |> Dict.get message
        |> Maybe.withDefault []
        |> List.map appCmd
        |> Cmd.batch
        |> \cmd ->
             model ! [cmd, routeLogCmd <| OnBroadcast message]

      else
        model ! []


stringValueToCmd : (String -> Cmd Msg) -> JE.Value -> Cmd Msg
stringValueToCmd commandConstructor stringValue =
  case JD.decodeValue JD.string stringValue of
    Ok string ->
      commandConstructor string

    Err error ->
      Cmd.none


{-| Given a Location and Route, return whether the route should be run for this location.

    Regex matching is used for both `location.pathname` AND `location.pathname ++ location.search`.
-}
locationMatchesRegex : Location -> String -> Bool
locationMatchesRegex { pathname } pathRegex =
  Regex.contains (regex pathRegex) pathname


{-| Get a Cmd that will launch the given Elm app.
-}
appCmd : ElmApp -> Cmd Msg
appCmd elmApp =
  case elmApp of
    Worker elmAppName ->
      Ports.worker (elmAppName)

    WorkerWithFlags elmAppName flags ->
      Ports.workerWithFlags (elmAppName, flags)

    Embed elmAppName selector ->
      Ports.embed (elmAppName, selector)

    EmbedWithFlags elmAppName selector flags ->
      Ports.embedWithFlags (elmAppName, selector, flags)


routeLogCmd : RouteStrategy -> Cmd Msg
routeLogCmd strategy =
  strategy
  |> strategyToString
  |> \s -> "launchRoute | " ++ s
  |> Ports.routerLog


strategyToString : RouteStrategy -> String
strategyToString strategy =
  case strategy of
    NewPageLoadWithUrl url ->
      "NewPageLoadWithUrl " ++ url

    OnUrl url ->
      "OnUrl " ++ url

    OnBroadcast message ->
      "OnBroadcast " ++ message

    Immediately ->
      "Immediately"
