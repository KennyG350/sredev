module Filters.Update exposing (update, resetFiltersCmds)


import Maybe
import Json.Encode as JE
import Json.Decode as JD exposing (decodeValue)
import Ports.Dom as Dom
import Ports.PubSub as PubSub
import SearchParameters
import Filters.Types exposing (..)
import Filters.Types.FormSubmission as FormSubmission exposing (FormSubmission)


type alias PartialFormSubmission =
  { price_min : String
  , price_max : String
  , bedrooms : String
  , bathrooms : String
  , home_size_min : String
  , lot_size_min : String
  , year_built_min : String
  }


type alias PropertyTypePayload =
  { property_type_house : Bool
  , property_type_townhouse : Bool
  , property_type_condo : Bool
  }


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveBroadcast ("searchParametersInitialized", params) ->
      update
        (SetFiltersFromSearchParameters <| SearchParameters.fromJson params)
        model

    ReceiveBroadcast ("performNewCardsSearch", params) ->
      update
        (SetFiltersFromSearchParameters <| SearchParameters.fromJson params)
        model

    SetFiltersFromSearchParameters params ->
      (params, resetFiltersCmds params)

    OnClick (".elm-search-properties-toggle-filters", _, _) ->
      (model, resetFiltersCmds model)

    OnClick (".elm-filters-clear-button", _, _) ->
      (model, clearFiltersCmds)

    OnSubmit (_, payload) ->
      case decodeFormSubmission payload of
        Just formSubmission ->
          formSubmission
          |> FormSubmission.applyToSearch model
          |> \searchParameters ->
               ( searchParameters
               , PubSub.broadcast
                   ( "searchFiltersChanged"
                   , SearchParameters.toJson searchParameters
                   )
               )

        Nothing ->
          model ! []

    _ ->
      model ! []


resetFiltersCmds : Model -> Cmd Msg
resetFiltersCmds params =
  params
  |> FormSubmission.fromSearchParameters
  |> \formSubmission ->
       Cmd.batch
         [ setRoomsCmd
             ".elm-filters-room-bedrooms"
             ".elm-filters-rooms-label-bedrooms"
             formSubmission.bedrooms
         , setRoomsCmd
             ".elm-filters-room-bathrooms"
             ".elm-filters-rooms-label-bathrooms"
             formSubmission.bathrooms
         , setPropertyTypeCmd ".elm-filters-property-type-house" formSubmission.property_type_house
         , setPropertyTypeCmd ".elm-filters-property-type-townhouse" formSubmission.property_type_townhouse
         , setPropertyTypeCmd ".elm-filters-property-type-condo" formSubmission.property_type_condo
         , setDropdownCmd ".elm-filters-home_size_min" formSubmission.home_size_min
         , setDropdownCmd ".elm-filters-lot_size_min" formSubmission.lot_size_min
         , setDropdownCmd ".elm-filters-year_built_min" formSubmission.year_built_min
         , setPriceRangeCmd formSubmission.price_min formSubmission.price_max
         ]


clearFiltersCmds : Cmd Msg
clearFiltersCmds =
  Cmd.batch
    [ setRoomsCmd ".elm-filters-room-bedrooms" ".elm-filters-rooms-label-bedrooms" "0"
    , setRoomsCmd ".elm-filters-room-bathrooms" ".elm-filters-rooms-label-bathrooms" "0"
    , setPropertyTypeCmd ".elm-filters-property-type-house" True
    , setPropertyTypeCmd ".elm-filters-property-type-townhouse" True
    , setPropertyTypeCmd ".elm-filters-property-type-condo" True
    , setDropdownCmd ".elm-filters-home_size_min" ""
    , setDropdownCmd ".elm-filters-lot_size_min" ""
    , setDropdownCmd ".elm-filters-year_built_min" ""
    , setPriceRangeCmd "" ""
    ]


setRoomsCmd : String -> String -> String -> Cmd Msg
setRoomsCmd selector labelSelectorPrefix value =
  Dom.click <| labelSelectorPrefix ++ value


setPropertyTypeCmd : String -> Bool -> Cmd Msg
setPropertyTypeCmd selector includePropertyType =
  Dom.setProperty
    ( selector
    , "checked"
    , JE.bool includePropertyType
    )


setDropdownCmd : String -> String -> Cmd Msg
setDropdownCmd selector value =
  Dom.setProperty (selector, "value", JE.string value)


setPriceRangeCmd : String -> String -> Cmd Msg
setPriceRangeCmd minimum maximum =
  PubSub.broadcast
    ( "setPriceRange"
    , JE.object
        [ ("minimum", JE.string minimum)
        , ("maximum", JE.string maximum)
        ]
    )


decodeFormSubmission : JE.Value -> Maybe FormSubmission
decodeFormSubmission payload =
  case (decodeValue partialSubmissionDecoder payload, decodeValue propertyTypesDecoder payload) of
    (Ok partialSubmission, Ok propertyTypes) ->
      let
          { price_min, price_max, bedrooms, bathrooms
          , home_size_min, lot_size_min, year_built_min
          } = partialSubmission

          { property_type_house
          , property_type_townhouse
          , property_type_condo
          } = propertyTypes
      in
        Just <| FormSubmission
          price_min
          price_max
          property_type_house
          property_type_townhouse
          property_type_condo
          bedrooms
          bathrooms
          home_size_min
          lot_size_min
          year_built_min

    _ ->
      Nothing


partialSubmissionDecoder : JD.Decoder PartialFormSubmission
partialSubmissionDecoder =
  JD.map7 PartialFormSubmission
    (JD.field "price_min" JD.string)
    (JD.field "price_max" JD.string)
    (JD.field "bedrooms" JD.string)
    (JD.field "bathrooms" JD.string)
    (JD.field "home_size_min" JD.string)
    (JD.field "lot_size_min" JD.string)
    (JD.field "year_built_min" JD.string)


propertyTypesDecoder : JD.Decoder PropertyTypePayload
propertyTypesDecoder =
  JD.map3 PropertyTypePayload
    (JD.field "property_type_house" JD.bool)
    (JD.field "property_type_townhouse" JD.bool)
    (JD.field "property_type_condo" JD.bool)
