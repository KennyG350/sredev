port module Monarch.Ports exposing (..)


import Monarch.Types exposing (..)


-- Send to JS (Cmd)
port worker : ElmAppName -> Cmd msg
port workerWithFlags : (ElmAppName, Flags) -> Cmd msg
port embed : (ElmAppName, Selector) -> Cmd msg
port embedWithFlags : (ElmAppName, Selector, Flags) -> Cmd msg
port refreshBrowser : () -> Cmd msg
port routerLog : String -> Cmd msg
