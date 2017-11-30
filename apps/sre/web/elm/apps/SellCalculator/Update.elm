module SellCalculator.Update exposing (update, updateReadOnlyDomCmd, setInputValueCmd)


import String
import Result
import Maybe
import Json.Encode as JE
import Ports.Dom as Dom
import NumberFormatter exposing (stripNonNumerics)
import SellCalculator.Types exposing (..)
import SellCalculator.Calculator as Calculator


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OnInput (".elm-sell-calculator-price", { value }, _) ->
      case value of
        Just priceString ->
          let
            price =
              if (String.length <| stripNonNumerics priceString) >= 5 then
                priceString
                |> stripNonNumerics
                |> String.toFloat
                |> Result.map floor
                |> Result.map toFloat
                |> Result.map Price
                |> Result.withDefault model.price

              else
                model.price

            model_ = { model | price = price }
          in
            ( model_
            , updateReadOnlyDomCmd model_
            )

        Nothing ->
          model ! []

    OnBlur (".elm-sell-calculator-price", _, _) ->
      (model, setInputValueCmd model.price)

    OnChange (".elm-sell-calculator-percent", { value }, _) ->
      case value of
        Just priceString ->
          priceString
          |> percentFromString
          |> Result.withDefault model.percentToBuyerAgent
          |> \percent_ ->
               { model | percentToBuyerAgent = percent_ }
          |> \model ->
               ( model
               , updateReadOnlyDomCmd model
               )

        Nothing ->
          model ! []

    _ ->
      model ! []


updateReadOnlyDomCmd : Model -> Cmd Msg
updateReadOnlyDomCmd model =
  let
    { srePercent, sreFee, traditionalFee, savings } = Calculator.calculation model
  in
    Cmd.batch
      [ Dom.innerHtml (".elm-percent-to-buyer-agent", percentToString model.percentToBuyerAgent)
      , Dom.innerHtml (".elm-sre-total-percent", percentToString srePercent)
      , Dom.innerHtml (".elm-sre-total-fee", priceToString sreFee)
      , Dom.innerHtml (".elm-traditional-total-fee", priceToString traditionalFee)
      , Dom.innerHtml (".elm-estimated-savings-with-sre", priceToString savings)
      ]


setInputValueCmd : Price -> Cmd Msg
setInputValueCmd price =
  Dom.setProperty (".elm-sell-calculator-price", "value", JE.string <| priceToString price)
