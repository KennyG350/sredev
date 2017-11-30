module Test.AppSwitch exposing (tests)


import Html exposing (Html)
import Time exposing (every, second, Time)
import Test exposing (test, describe, Test)
import Expect
import AppSwitch exposing (AppSwitch)


type alias MockModel =
  { appSwitch : AppSwitch
  , counter : Int
  }


type MockMsg
  = Tick Time


tests : Test
tests =
  describe "AppSwitch"
    [ describe "subscriptions"
        [ test "Sub.none is returned if the AppSwitch is Off" <|
            \() ->
              offModel
              |> AppSwitch.subscriptions .appSwitch mockSubscriptions
              |> Expect.equal Sub.none
        , test "`subscriptions_` is run and result is returned if the AppSwitch is On" <|
            \() ->
              onModel
              |> AppSwitch.subscriptions .appSwitch mockSubscriptions
              |> Expect.equal (every second Tick)
        ]
    , describe "update"
        [ test "`model ! []` is returned if the AppSwitch is Off" <|
            \() ->
              offModel
              |> AppSwitch.update .appSwitch mockUpdate (Tick 100)
              |> Expect.equal (offModel ! [])
        , test "`update_` is run and result is returned if the AppSwitch is On" <|
            \() ->
              onModel
              |> AppSwitch.update .appSwitch mockUpdate (Tick 100)
              |> Expect.equal ({ onModel | counter = onModel.counter + 1 } ! [])
        ]
    , describe "view"
        [ test "`Html.text \"\"` is returned if the AppSwitch is Off" <|
            \() ->
              offModel
              |> AppSwitch.view .appSwitch mockView
              |> Expect.equal (Html.text "")
        , test "`view_` is run and result is returned if the AppSwitch is On" <|
            \() ->
              onModel
              |> AppSwitch.view .appSwitch mockView
              |> Expect.equal (Html.text "App on (text rendered)")
        ]
    ]


offModel : MockModel
offModel = MockModel AppSwitch.Off 0


onModel : MockModel
onModel = MockModel AppSwitch.On 0


mockSubscriptions : MockModel -> Sub MockMsg
mockSubscriptions model =
  every second Tick


mockUpdate : MockMsg -> MockModel -> (MockModel, Cmd MockMsg)
mockUpdate msg model =
  case msg of
    Tick _ ->
      { model | counter = model.counter + 1 } ! []


mockView : MockModel -> Html MockMsg
mockView model =
  Html.text "App on (text rendered)"
