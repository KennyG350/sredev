module SellCalculator.Calculator exposing (calculation)


import SellCalculator.Types exposing (..)


calculation : Model -> Calculation
calculation { price, percentToBuyerAgent } =
  let
    price_ = priceToFloat price
    srePercent =
      0.01 -- 1% to SRE
      + percentToFloat percentToBuyerAgent -- % to buyer agent
    sreFee = toFloat <| round <| price_ * srePercent
    traditionalFee = toFloat <| round <| price_ * 0.06 -- 3% to seller agent, 3% to buyer agent
  in
    Calculation
      (Result.withDefault One <| percentFromFloat srePercent)
      (Price sreFee)
      (Price traditionalFee)
      (Price <| traditionalFee - sreFee)
