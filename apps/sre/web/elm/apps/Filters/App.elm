module Filters.App exposing (..)


{-| Upon instantiation or filter reset, manually reset all filters from the URL params.

    When "View Results" is clicked, update the URL and broadcast that a new search needs to happen.
-}


import Ports.Dom as Dom
import Ports.PubSub as PubSub
import SearchParameters
import Filters.Types exposing (..)
import Filters.Update exposing (update, resetFiltersCmds)


main : Program Never Model Msg
main =
  Platform.program
    { init = init
    , subscriptions = subscriptions
    , update = update
    }


init : (Model, Cmd Msg)
init =
  SearchParameters.empty !
  [ resetFiltersCmds SearchParameters.empty
  , Dom.addClickListener ".elm-filters-clear-button"
  , Dom.addClickListener ".elm-search-properties-toggle-filters"
  , Dom.addSubmitListener
      ( ".elm-search-filters-form"
      , [ "price_min"
        , "price_max"
        , "property_type_house"
        , "property_type_townhouse"
        , "property_type_condo"
        , "bedrooms"
        , "bathrooms"
        , "home_size_min"
        , "lot_size_min"
        , "year_built_min"
        ]
      )
  ]


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ Dom.onClick OnClick
    , Dom.onSubmit OnSubmit
    , PubSub.receiveBroadcast ReceiveBroadcast
    ]
