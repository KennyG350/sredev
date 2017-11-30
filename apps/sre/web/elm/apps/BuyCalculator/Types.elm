module BuyCalculator.Types exposing (..)


import Array exposing (Array)
import Ports.PubSub as PubSub


type Msg
  = ReceiveBroadcast (PubSub.Message, PubSub.Payload)


type alias SliderOptions = Array Int


type alias Model =
  { sliderOptions : SliderOptions
  , sliderOptionsLength : Int
  , rebateMultiplier : Float
  }


type alias Flags =
  { sliderOptions : Array Int
  , rebateMultiplier : Float
  }
