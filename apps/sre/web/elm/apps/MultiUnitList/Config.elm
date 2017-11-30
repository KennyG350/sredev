module MultiUnitList.Config exposing (..)


-- Websocket
websocketTopic : String
websocketTopic = "listing_list:multi_unit_modal"
websocketEventRequest : String
websocketEventRequest = "request_listing_list"
websocketEventReceive : String
websocketEventReceive = "receive_listing_list"


-- Selectors
containerSelector : String
containerSelector = ".elm-search-property-contents"
clickTargetSelector : String
clickTargetSelector = ".elm-search-property-contents .elm-listing-link"
