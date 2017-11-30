module Slider.Update exposing (update)


import Time
import Json.Encode as JE
import Debounce
import Ports.PubSub as PubSub
import Ports.Dom as Dom
import Slider.Types exposing (..)
import Slider.Types.KnobPosition as KnobPosition exposing (KnobPosition(..))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NodePosition (selector, position) ->
      let
        model_ =
          if selector == model.containerSelector then
            { model | containerPosition = Just position }

          else
            { model | initialBroadcastSent = True }
      in
        position
        |> nodePositionResponse model_ selector
        |> Maybe.map nodePositionResponseCmd
        |> Maybe.withDefault Cmd.none
        |> \cmd -> (model_, cmd)

    OnMouseDown (selector, _, { clientX }) ->
      if selector == model.knobSelector then
        { model | dragState = MouseDragging } ! []

      else if selector == model.rangeBarSelector then
        case clientX of
          Just clientX_ ->
            update
              (UpdateKnobPosition clientX_)
              { model | dragState = MouseDragging }

          Nothing ->
            model ! []

      else
        model ! []

    OnMouseMove { x } ->
      update (UpdateKnobPosition <| toFloat x) model

    OnMouseUp _ ->
      { model | dragState = NotDragging } ! []

    OnTouchStart (selector, htmlElement, event) ->
      if selector == model.knobSelector then
        { model | dragState = TouchDragging } ! []

      else if selector == model.rangeBarSelector then
        update
          (OnTouchMove (selector, htmlElement, event))
          { model | dragState = TouchDragging }

      else
        model ! []

    OnTouchMove (_, _, { touchClientX }) ->
      case touchClientX of
        Just clientX ->
          update (UpdateKnobPosition clientX) model

        Nothing ->
          model ! []

    OnTouchEnd _ ->
      { model | dragState = NotDragging } ! []

    OnResize ("window", _, _) ->
      let
        (throttleState, cmd) = Debounce.push resizeDebounceConfig () model.resizeThrottleState
      in
        ({ model | resizeThrottleState = throttleState }, cmd)

    UpdateKnobPosition knobXCoordinate ->
      case model.containerPosition of
        Just containerPosition ->
          let
            knobPosition =
              KnobPosition.fromContainerPositionAndFloat containerPosition knobXCoordinate

            (throttleState, throttleCmd) = Debounce.push
              knobBroadcastDebounceConfig
              knobPosition
              model.knobBroadcastThrottleState
          in
            { model | knobBroadcastThrottleState = throttleState } !
            [ Dom.setCssProperty
                ( model.knobSelector
                , "left"
                , KnobPosition.toCssPercent knobPosition
                )
            , throttleCmd
            ]

        Nothing ->
          model ! []

    ThrottleResize throttleMsg ->
      let
        (throttleState, cmd) =
          Debounce.update resizeDebounceConfig
            (Debounce.takeLast <| always <| Dom.getNodePosition model.containerSelector)
            throttleMsg
            model.resizeThrottleState
      in
        ({ model | resizeThrottleState = throttleState }, cmd)

    ThrottleKnobBroadcast throttleMsg ->
      let
        (throttleState, cmd) =
          Debounce.update
            knobBroadcastDebounceConfig
            (Debounce.takeLast knobPositionBroadcastCmd)
            throttleMsg
            model.knobBroadcastThrottleState
      in
        ({ model | knobBroadcastThrottleState = throttleState }, cmd)

    _ ->
      model ! []


nodePositionResponse : Model -> String -> Dom.Position -> Maybe NodePositionResponse
nodePositionResponse model selector position =
  let
    { containerSelector, containerPosition, knobSelector, initialBroadcastSent } = model
  in
    if selector == containerSelector then
      if initialBroadcastSent then
        Nothing

      else
        Just (GetKnobPosition knobSelector)

    else if selector == knobSelector then -- Should happen only once, soon after init
      case containerPosition of
        Just containerPosition ->
          Just (BroadcastKnobPosition containerPosition position)

        Nothing ->
          Nothing

    else
      Nothing


nodePositionResponseCmd : NodePositionResponse -> Cmd Msg
nodePositionResponseCmd reaction =
  case reaction of
    GetKnobPosition knobSelector ->
      Dom.getNodePosition knobSelector

    BroadcastKnobPosition containerPosition knobPosition ->
      let
        knobCenter = (knobPosition.right + knobPosition.left) / 2
      in
        knobCenter
        |> KnobPosition.fromContainerPositionAndFloat containerPosition
        |> \(Position position) ->
             PubSub.broadcast
               ( "sliderKnobPositionInitialized"
               , JE.float position
               )


knobPositionBroadcastCmd : KnobPosition -> Cmd Msg
knobPositionBroadcastCmd (Position position) =
  PubSub.broadcast
    ( "sliderKnobPositionUpdated"
    , JE.float position
    )


resizeDebounceConfig : Debounce.Config Msg
resizeDebounceConfig =
  { strategy = Debounce.soon (750 * Time.millisecond)
  , transform = ThrottleResize
  }


knobBroadcastDebounceConfig : Debounce.Config Msg
knobBroadcastDebounceConfig =
  { strategy = Debounce.soon (30 * Time.millisecond)
  , transform = ThrottleKnobBroadcast
  }
