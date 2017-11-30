module FeedMaps.Types.Feed exposing (..)


import Json.Decode as JD
import Ports.GoogleMaps as GoogleMaps


type alias Feed =
  { bounds : String
  , latLng : GoogleMaps.LatLng
  , city : String
  , state : String
  }


toMarker : Feed -> GoogleMaps.Marker
toMarker { bounds, latLng, city, state } =
  { latLng = latLng
  , name = city ++ ", " ++ state
  }


decoder : JD.Decoder Feed
decoder =
  JD.map4 Feed
    (JD.field "bounds" JD.string)
    (JD.field "latLng" GoogleMaps.latLngDecoder)
    (JD.field "city" JD.string)
    (JD.field "state" JD.string)
