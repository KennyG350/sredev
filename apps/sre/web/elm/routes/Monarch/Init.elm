module Monarch.Init exposing (init)


import Dict exposing (Dict)
import Navigation exposing (Location)
import Ports.PubSub exposing (Message)
import Monarch.Types exposing (..)
import Monarch.Update exposing (appCmd, routeLogCmd, locationMatchesRegex)
import Routes


init : Location -> (Model, Cmd Msg)
init location =
  let
    routes = Routes.routes location
  in
    { location = location
    , routesOnUrl = routesOnUrl routes
    , routesOnBroadcast = routesOnBroadcast routes
    , newPageLoadWithUrlRoutes = newPageLoadWithUrlRoutes routes
    } !
    (immediateRouteCmds location routes)


routesOnUrl : List Route -> Dict Url (List ElmApp)
routesOnUrl routes =
  routes
  |> List.map onUrlTuple
  |> List.foldl maybeToListAccumulator []
  |> Dict.fromList


onUrlTuple : Route -> Maybe (Url, List ElmApp)
onUrlTuple { strategy, elmApps } =
  case strategy of
    OnUrl url ->
      Just (url, elmApps)

    _ ->
      Nothing


routesOnBroadcast : List Route -> Dict Message (List ElmApp)
routesOnBroadcast routes =
  routes
  |> List.map onBroadcastTuple
  |> List.foldl maybeToListAccumulator []
  |> Dict.fromList


onBroadcastTuple : Route -> Maybe (Url, List ElmApp)
onBroadcastTuple { strategy, elmApps } =
  case strategy of
    OnBroadcast message ->
      Just (message, elmApps)

    _ ->
      Nothing


newPageLoadWithUrlRoutes : List Route -> List String
newPageLoadWithUrlRoutes routes =
  routes
  |> List.map .strategy
  |> List.map urlOnPageLoad
  |> List.foldl maybeToListAccumulator []


urlOnPageLoad : RouteStrategy -> Maybe String
urlOnPageLoad strategy =
  case strategy of
    NewPageLoadWithUrl url ->
      Just url

    _ ->
      Nothing


immediateRouteCmds : Location -> List Route -> List (Cmd Msg)
immediateRouteCmds location routes =
  let
    routesToLaunch =
      routes
      |> List.filter (launchImmediately location)
  in
    [ routesToLaunch
        |> List.map .strategy
        |> List.map routeLogCmd
        |> Cmd.batch
    , routesToLaunch
        |> List.map .elmApps
        |> List.concat
        |> List.map appCmd
        |> Cmd.batch
    ]


launchImmediately : Location -> Route -> Bool
launchImmediately location { strategy } =
  case strategy of
    Immediately ->
      True

    NewPageLoadWithUrl url ->
      locationMatchesRegex location url

    OnUrl url ->
      locationMatchesRegex location url

    _ ->
      False


maybeToListAccumulator : Maybe a -> List a -> List a
maybeToListAccumulator maybeValue listOfValues =
  case maybeValue of
    Just a ->
      a :: listOfValues

    Nothing ->
      listOfValues
