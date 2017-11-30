module FeedMaps.MapStyles exposing (mapStyles)


import Color exposing (white, lightPurple)
import Ports.GoogleMaps.Style exposing (Style, FeatureType(..), ElementType(..), Styler(..), Visibility(..), hexToColor)


mapStyles : List Style
mapStyles =
  [ Style Water GeometryFill
      [ Color <| hexToColor "#FFFFFF"
      ]
  , Style Transit AllElements
      [ Color <| hexToColor "#808080"
      , Visibility VisibilityOff
      ]
  , Style RoadHighway GeometryStroke
      [ Visibility VisibilityOn
      , Color <| hexToColor "#b3b3b3"
      ]
  , Style RoadHighway GeometryFill
      [ Color white
      ]
  , Style RoadLocal GeometryFill
      [ Visibility VisibilityOn
      , Color white
      , Weight 1.8
      ]
  , Style RoadLocal GeometryStroke
      [ Color <| hexToColor "#d7d7d7"
      ]
  , Style Poi GeometryFill
      [ Visibility VisibilityOn
      , Color <| hexToColor "#ebebeb"
      ]
  , Style Administrative Geometry
      [ Color <| hexToColor "#a7a7a7"
      ]
  , Style RoadArterial GeometryFill
      [ Color white
      ]
  , Style Landscape GeometryFill
      [ Visibility VisibilityOn
      , Color <| hexToColor "#efefef"
      ]
  , Style Road LabelsTextFill
      [ Color <| hexToColor "#696969"
      ]
  , Style Administrative LabelsTextFill
      [ Visibility VisibilityOn
      , Color <| hexToColor "#737373"
      ]
  , Style Poi LabelsIcon
      [ Visibility VisibilityOff
      ]
  , Style Poi Labels
      [ Visibility VisibilityOff
      ]
  , Style RoadArterial GeometryStroke
      [ Color <| hexToColor "#d6d6d6"
      ]
  , Style Road LabelsIcon
      [ Visibility VisibilityOff
      ]
  , Style Poi GeometryFill
      [ Color <| hexToColor "#dadada"
      ]
  ]
