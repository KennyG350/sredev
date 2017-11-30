module Filters.RangeSlider.Types.Knob exposing (..)


import Json.Decode as JD
import Json.Encode as JE


type Knob
  = LeftKnob
  | RightKnob


knobToString : Knob -> String
knobToString knob =
  case knob of
    LeftKnob ->
      "LeftKnob"

    RightKnob ->
      "RightKnob"


knobFromString : String -> Maybe Knob
knobFromString string =
  case string of
    "LeftKnob" ->
      Just LeftKnob

    "RightKnob" ->
      Just RightKnob

    _ ->
      Nothing


type alias KnobPositionUpdate =
  { knob : Knob
  , position : Float -- 0 = 0%, 1 = 100%, 0.5 = 50%
  }


type alias SerializableKnobPositionUpdate =
  { knob : String
  , position : Float
  }


encodeKnobPositionUpdate : KnobPositionUpdate -> JE.Value
encodeKnobPositionUpdate { knob, position } =
  JE.object
    [ ("knob", JE.string <| knobToString knob)
    , ("position", JE.float position)
    ]


decodeKnobPositionUpdate : JE.Value -> Result String KnobPositionUpdate
decodeKnobPositionUpdate update =
  case JD.decodeValue knobPositionUpdateDecoder update of
    Ok { knob, position } ->
      case knobFromString knob of
         Just knob_ ->
           Ok (KnobPositionUpdate knob_ position)

         Nothing ->
           Err ("Invalid knob string: " ++ knob)

    Err error ->
      Err error


knobPositionUpdateDecoder : JD.Decoder SerializableKnobPositionUpdate
knobPositionUpdateDecoder =
  JD.map2 SerializableKnobPositionUpdate
    (JD.field "knob" JD.string)
    (JD.field "position" JD.float)
