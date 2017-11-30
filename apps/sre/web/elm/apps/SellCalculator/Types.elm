module SellCalculator.Types exposing (..)


import NumberFormatter
import Ports.Dom as Dom


type Msg
  = OnInput (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnBlur (Dom.Selector, Dom.HtmlElement, Dom.Event)
  | OnChange (Dom.Selector, Dom.HtmlElement, Dom.Event)


type alias Model =
  { price : Price
  , percentToBuyerAgent : Percent
  }


type alias Calculation =
  { srePercent : Percent
  , sreFee : Price
  , traditionalFee : Price
  , savings : Price
  }


type alias Flags =
  { initialPrice : Float
  , initialPercent : Float
  }


-- Percent


type Percent
  = One
  | OneAndAHalf
  | Two
  | TwoAndAHalf
  | Three
  | ThreeAndAHalf
  | Four


percentFromFloat : Float -> Result String Percent
percentFromFloat percent =
  case percent of
    0.01 ->
      Ok One

    0.015 ->
      Ok OneAndAHalf

    0.02 ->
      Ok Two

    0.025 ->
      Ok TwoAndAHalf

    0.03 ->
      Ok Three

    0.035 ->
      Ok ThreeAndAHalf

    0.04 ->
      Ok Four

    _ ->
      Err "Invalid percent"


percentToFloat : Percent -> Float
percentToFloat percent =
  case percent of
    One ->
      0.01

    OneAndAHalf ->
      0.015

    Two ->
      0.02

    TwoAndAHalf ->
      0.025

    Three ->
      0.03

    ThreeAndAHalf ->
      0.035

    Four ->
      0.04


percentToString : Percent -> String
percentToString percent =
  case percent of
    One ->
      "1%"

    OneAndAHalf ->
      "1.5%"

    Two ->
      "2%"

    TwoAndAHalf ->
      "2.5%"

    Three ->
      "3%"

    ThreeAndAHalf ->
      "3.5%"

    Four ->
      "4%"


percentFromString : String -> Result String Percent
percentFromString percent =
  case percent of
    "1" ->
      Ok One

    "1.5" ->
      Ok OneAndAHalf

    "2" ->
      Ok Two

    "2.5" ->
      Ok TwoAndAHalf

    "3" ->
      Ok Three

    "3.5" ->
      Ok ThreeAndAHalf

    "4" ->
      Ok Four

    _ ->
      Err "Invalid percent"


-- Price


type Price -- Wrap floats to ensure they're run through the priceToString formatter
  = Price Float


priceToString : Price -> String
priceToString (Price price) =
  NumberFormatter.floatToCurrency price


priceToFloat : Price -> Float
priceToFloat (Price price) =
  price
