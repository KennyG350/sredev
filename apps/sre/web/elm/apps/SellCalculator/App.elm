module SellCalculator.App exposing (main)


import SellCalculator.Types exposing (..)
import SellCalculator.Update exposing (update, updateReadOnlyDomCmd, setInputValueCmd)
import Ports.Dom as Dom


fallbackPercent : Percent
fallbackPercent = One


main : Program Flags Model Msg
main =
  Platform.programWithFlags
    { init = init
    , update = update
    , subscriptions = subscriptions
    }


init : Flags -> (Model, Cmd Msg)
init { initialPrice, initialPercent } =
  let
    percentToBuyerAgent =
      case percentFromFloat initialPercent of
        Ok percent ->
          percent

        Err _ ->
          fallbackPercent

    model = Model (Price initialPrice) percentToBuyerAgent
  in
    model !
    [ Dom.addEventListener (".elm-sell-calculator-price", "input", Nothing)
    , Dom.addEventListener (".elm-sell-calculator-price", "blur", Nothing)
    , Dom.addEventListener (".elm-sell-calculator-percent", "change", Nothing)
    , updateReadOnlyDomCmd model
    , setInputValueCmd model.price
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onChange OnChange
    , Dom.onInput OnInput
    , Dom.onBlur OnBlur
    ]
