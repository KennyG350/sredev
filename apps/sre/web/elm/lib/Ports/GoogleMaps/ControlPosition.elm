module Ports.GoogleMaps.ControlPosition exposing (..)


type ControlPosition
  = BOTTOM
  | BOTTOM_CENTER
  | BOTTOM_LEFT
  | BOTTOM_RIGHT
  | CENTER
  | LEFT
  | LEFT_BOTTOM
  | LEFT_CENTER
  | LEFT_TOP
  | RIGHT
  | RIGHT_BOTTOM
  | RIGHT_CENTER
  | RIGHT_TOP
  | TOP
  | TOP_CENTER
  | TOP_LEFT
  | TOP_RIGHT


toString : ControlPosition -> String
toString position =
  case position of
    BOTTOM ->
      "BOTTOM"

    BOTTOM_CENTER ->
      "BOTTOM_CENTER"

    BOTTOM_LEFT ->
      "BOTTOM_LEFT"

    BOTTOM_RIGHT ->
      "BOTTOM_RIGHT"

    CENTER ->
      "CENTER"

    LEFT ->
      "LEFT"

    LEFT_BOTTOM ->
      "LEFT_BOTTOM"

    LEFT_CENTER ->
      "LEFT_CENTER"

    LEFT_TOP ->
      "LEFT_TOP"

    RIGHT ->
      "RIGHT"

    RIGHT_BOTTOM ->
      "RIGHT_BOTTOM"

    RIGHT_CENTER ->
      "RIGHT_CENTER"

    RIGHT_TOP ->
      "RIGHT_TOP"

    TOP ->
      "TOP"

    TOP_CENTER ->
      "TOP_CENTER"

    TOP_LEFT ->
      "TOP_LEFT"

    TOP_RIGHT ->
      "TOP_RIGHT"


toMaybeString : ControlPosition -> Maybe String
toMaybeString = toString >> Just
