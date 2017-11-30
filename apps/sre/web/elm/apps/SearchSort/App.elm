module SearchSort.App exposing (main)


import Json.Encode as JE
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import SearchParameters


type alias QueryParams = String
type alias Selector = String


type alias Model = ()


type Msg
  = HandleChange (Selector, Dom.HtmlElement, Dom.Event)
  | ReceiveBroadcast (PubSub.Message, PubSub.Payload)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  ( ()
  , Dom.addEventListener (".elm-change-sort-order", "change", Nothing)
  )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Dom.onChange HandleChange
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HandleChange (_, { value }, _) -> -- No need to constrain selector; only one listener is registered
      case value of
        Just sortOption ->
          ( model
          , PubSub.broadcast
              ( "searchSortChanged"
              , JE.string sortOption
              )
          )

        Nothing ->
          model ! []

    ReceiveBroadcast ("performNewCardsSearch", searchParameters) ->
      searchParameters
      |> SearchParameters.fromJson
      |> .sort
      |> SearchParameters.sortOptionToString
      |> \sortValue ->
           ( ()
           , Dom.setProperty
               ( ".elm-change-sort-order"
               , "value"
               , JE.string sortValue
               )
           )

    _ ->
      model ! []
