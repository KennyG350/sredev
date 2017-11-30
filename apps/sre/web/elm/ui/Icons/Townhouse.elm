module Icons.Townhouse exposing (view)


import Html exposing (Html, text)
import Svg exposing (svg, title, g, path)
import Svg.Attributes exposing (width, height, viewBox, fill, fillRule, d)
import VirtualDom exposing (attribute)


view : Html msg
view =
  svg
    [ width "69", height "40", viewBox "0 0 69 40", attribute "xmlns" "http://www.w3.org/2000/svg" ]
    [ title [] [ text "Townhouse" ]
    , g
        [ fill "none", fillRule "evenodd" ]
        [ path
            [ fill "#1292C9"
            , d <| "M24.604 30.248h5.7v-2.5h-5.7M24.564 21.967h5.7v-2.5h-5.7M12.362 21.967h5.7v-2.5h-"
                ++ "5.7M24.564 17.02h5.7v-2.5h-5.7M12.362 17.02h5.7v-2.5h-5.7"
            ]
            []
        , path
            [ fill "#9297A5"
            , d <| "M21.108 0L6.692 10.967v26.13H0v2.5h42.705v-2.5h-6.692V10.954L21.108 0zm.026 3.152"
                ++ "l10.613 7.8H10.883l10.25-7.8zM9.26 23.453h24.185v-10H9.26v10zm0 2.5h24.185v11."
                ++ "145H21.13V27.75H12.3v9.347H9.26V25.95zm5.61 11.142h3.692v-6.846H14.87v6.846z"
            ]
            []
        , path
            [ fill "#1292C9"
            , d <| "M39.142 30.248h5.7v-2.5h-5.7M39.182 21.967h5.7v-2.5h-5.7M51.384 21.967h5.7v-2.5h-"
                ++ "5.7M39.182 17.02h5.7v-2.5h-5.7M51.384 17.02h5.7v-2.5h-5.7"
            ]
            []
        , path
            [ fill "#9297A5"
            , d <| "M48.338 0l-2.87 2.11-12.036 8.844v26.143h-6.69v2.5h42.704v-2.5h-6.693v-26.13L48.3"
                ++ "38 0zm-.027 3.152l10.252 7.8H37.698l10.613-7.8zM36 23.453h24.185v-10H36v10zm0 "
                ++ "2.5h24.184v11.145h-3.04V27.75h-8.83v9.347H36.002V25.95zm14.884 11.142h3.693v-6"
                ++ ".846h-3.693v6.846z"
            ]
            []
        ]
    ]
