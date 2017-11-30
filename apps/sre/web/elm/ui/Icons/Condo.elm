module Icons.Condo exposing (view)


import Html exposing (Html, text)
import Svg exposing (svg, title, g, path)
import Svg.Attributes exposing (width, height, viewBox, fill, fillRule, d)
import VirtualDom exposing (attribute)


view : Html msg
view =
  svg
    [ width "43", height "40", viewBox "0 0 43 40", attribute "xmlns" "http://www.w3.org/2000/svg" ]
    [ title [] [ text "Condo" ]
    , g
        [ fill "none", fillRule "evenodd" ]
        [ path
            [ fill "#2093C8"
            , d <| "M26.268 35.005h8.866v-2.623h-8.866M26.268 30.743h8.866V28.12h-8.866M26.268 26.482"
                ++ "h8.866V23.86h-8.866M26.268 22.22h8.866v-2.624h-8.866M26.268 17.956h8.866v-2.62"
                ++ "3h-8.866M9.522 35.005h8.865v-2.623H9.522M9.522 30.17h8.865v-2.624H9.522M9.522 "
                ++ "25.334h8.865V22.71H9.522M9.522 20.497h8.865v-2.623H9.522M9.522 15.66h8.865V13."
                ++ "04H9.522"
            ]
            []
        , path
            [ fill "#9297A5"
            , d <| "M23.97 0L3.884 11.316v25.902H0v2.623H43.67V37.22h-3.884V10.443H23.97V0zM6.51 12.8"
                ++ "48l14.83-8.357V37.22H6.512v-24.37zm17.457 24.37h13.19V13.065H23.97v24.153z"
            ]
            []
        ]
    ]
