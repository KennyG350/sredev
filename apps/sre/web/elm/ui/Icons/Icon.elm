module Icons.Icon exposing (view, Icon(..), IconSize(..))

import Html exposing (Html, span)
import Svg exposing (svg, path, g)
import Html.Attributes exposing (class)
import Svg.Attributes as SA exposing (viewBox, d, fillRule)
import VirtualDom exposing (attribute)
import String exposing (join)
import Maybe exposing (withDefault)


type Icon
  = ArrowRight
  | ArrowLeft
  | CaretLeft
  | CaretRight
  | Close
  | Grid
  | List
  | Map
  | Minus
  | Plus
  | Warning


type IconSize
  = Xs
  | Sm
  | Md
  | Lg
  | Xl
  | Default


view : IconSize -> Maybe String -> Icon -> Html a
view size classname icon =
  span [ class <| join " " [ "icon", getIconSizeClass size, withDefault "" classname ] ]
    [ svg [ SA.class "icon__svg", viewBox "0 0 48 48", attribute "xmlns" "http://www.w3.org/2000/svg" ]
        [ renderIcon icon ]
    ]


getIconSizeClass : IconSize -> String
getIconSizeClass size =
  case size of
    Xs ->
      "icon--xs"

    Sm ->
      "icon--sm"

    Md ->
      "icon--md"

    Lg ->
      "icon--lg"

    Xl ->
      "icon--xl"

    Default ->
      ""


renderIcon : Icon -> Html a
renderIcon name =
  case name of
    ArrowRight ->
      path [ fillRule "evenodd", d "M12.594 48l24.03-24.03L12.595-.063" ] []

    ArrowLeft ->
      path [ fillRule "evenodd", d "M36.625-.062l-24.03 24.03L36.624 48" ] []

    CaretLeft ->
      path [ fillRule "evenodd", d "M36.625-.062l-24.03 24.03L36.624 48" ] []

    CaretRight ->
      path [ fillRule "evenodd", d "M12.594 48l24.03-24.03L12.595-.063" ] []

    Close ->
      path [ fillRule "evenodd", d "M47 6.5L42.5 2l-18 18-18-18L2 6.5l18 18-18 18L6.5 47l18-18 18 18 4.5-4.5-18-18" ] []

    Grid ->
      path [ fillRule "evenodd", d "M2 13h11V2H2v11zm16.5 33h11V35h-11v11zM2 46h11V35H2v11zm0-16.5h11v-11H2v11zm16.5 0h11v-11h-11v11zM35 2v11h11V2H35zM18.5 13h11V2h-11v11zM35 29.5h11v-11H35v11zM35 46h11V35H35v11z" ] []

    List ->
      path [ fillRule "evenodd", d "M1 26.6h5.11v-5.2H1v5.2zM1 37h5.11v-5.2H1V37zm0-20.8h5.11V11H1v5.2zm10.222 10.4H47v-5.2H11.222v5.2zm0 10.4H47v-5.2H11.222V37zm0-26v5.2H47V11H11.222z" ] []

    Map ->
      path [ fillRule "evenodd", d "M45.722 1h-.51L31.666 6.367 16.333 1 2.023 5.856C1.51 6.11 1 6.366 1 7.133v38.59C1 46.488 1.51 47 2.278 47h.51l13.545-5.367L31.667 47l14.31-4.856C46.49 41.89 47 41.378 47 40.867V2.277C47 1.512 46.49 1 45.722 1zM31.667 41.89L16.333 36.52V6.112l15.334 5.366v30.41z" ] []

    Minus ->
      path [ fillRule "evenodd", d "M21.286 27.714H2v-6.428h45v6.428H27.714" ] []

    Plus ->
      path [ fillRule "evenodd", d "M21.286 27.714H2v-6.428h19.286V2h6.428v19.286H47v6.428H27.714V47h-6.428" ] []

    Warning ->
      path [ fillRule "evenodd", d "M47.71 44.205L23.856 3.81 0 44.205h47.71zM26.025 37.7h-4.337v-4.34h4.337v4.34zm0-8.676h-4.337V20.35h4.337v8.674z" ] []
