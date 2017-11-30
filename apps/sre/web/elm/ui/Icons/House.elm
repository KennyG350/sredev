module Icons.House exposing (view)


import Html exposing (Html)
import Svg exposing (svg, title, path, text)
import Svg.Attributes exposing (width, height, viewBox, fill, fillRule, d)
import VirtualDom exposing (attribute)


view : Html msg
view =
  svg
    [ width "38", height "40", viewBox "0 0 38 40", attribute "xmlns" "http://www.w3.org/2000/svg" ]
    [ title [] [ text "House" ]
    , path
        [ fill "#9297A5"
        , fillRule "evenodd"
        , d <| "M18.707 0L1.97 17.418v5.565h4.926v14.573H0v2.688h37.988v-2.688h-6.896V22.983h4.926v-5"
            ++ ".58l-.954-.96.003-12.158h-9.413l.005 2.704L18.706 0zM4.657 18.5L18.74 3.845l6.925 "
            ++ "6.963v.017l4.567 4.574 3.098 3.113v1.78H4.658V18.5zm27.572-4.905L28.35 9.697l-.005"
            ++ "-2.723h4.03l-.002 6.767-.146-.145zM9.583 22.99h18.82V37.55h-4.93v-10.98h-8.958v10."
            ++ "98H9.584V22.99zm7.62 14.562h3.58V29.26h-3.58v8.292z"
        ]
        []
    ]
