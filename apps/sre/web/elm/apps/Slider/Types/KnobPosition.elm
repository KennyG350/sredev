module Slider.Types.KnobPosition exposing (..)


import Ports.Dom as Dom


type KnobPosition
  = Position Float


fromFloat : Float -> KnobPosition
fromFloat float =
  if float < 0 then
    Position 0

  else if float > 1 then
    Position 1

  else
    Position float


fromInt : Int -> KnobPosition
fromInt = Basics.toFloat >> fromFloat


toFloat : KnobPosition -> Float
toFloat (Position float) = float


fromContainerPositionAndFloat : Dom.Position -> Float -> KnobPosition
fromContainerPositionAndFloat { left, right } knobX =
  fromFloat (
    (knobX - left) / (right - left)
  )


{-| Convert a KnobPosition to a percentage.

    toCssPercent Position 0.1 == "10%"
    toCssPercent Position 1 == "100%"
    toCssPercent Position 0 == "0%"
-}
toCssPercent : KnobPosition -> String
toCssPercent (Position position) =
  position * 100
  |> toString
  |> (flip String.append) "%"
