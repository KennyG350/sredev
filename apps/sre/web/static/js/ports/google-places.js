module.exports = {
  register: register,
  samplePortName: "requestGooglePlacesDetails"
};

const autocomplete = new google.maps.places.AutocompleteService();
const places = new google.maps.places.PlacesService(document.createElement("div"));

/**
 * Subscribe the given Elm app ports to all Google Places ports from the Elm GooglePlaces module.
 *
 * @param {Object}   ports  Ports object from an Elm app
 * @param {Function} log    Function to log ports for the given Elm app
 */
function register(ports, log) {
  ports.requestGooglePlacesDetails.subscribe(requestGooglePlacesDetails);
  ports.requestGooglePlacesPredictions.subscribe(requestGooglePlacesPredictions);

  /**
   * Request a PlaceResult details object for a given place ID.
   *
   * @link https://developers.google.com/maps/documentation/javascript/places#place_search_results
   * @param  {String} placeId The ID of the Place
   */
  function requestGooglePlacesDetails(placeId) {
    log("requestGooglePlacesDetails", placeId);

    places.getDetails({ placeId }, response => {
      response.bounds = getBoundsUrlValue(response);

      response.geometry = {
        location: {
          lat: response.geometry.location.lat(),
          lng: response.geometry.location.lng(),
        }
      };

      response.vicinity = response.vicinity || null;

      log("receiveGooglePlacesDetails", response);

      ports.receiveGooglePlacesDetails.send(response);
    });
  }

  /**
   * Request a list of AutocompletePrediction objects for a given search query.
   *
   * @link https://developers.google.com/maps/documentation/javascript/reference#AutocompletePrediction
   * @param  {String}        searchQuery   The search query to match
   * @param  {Array[String]} types         The types of predictions to be returned
   *                                       Four types are supported:
   *                                       'establishment' for businesses,
   *                                       'geocode' for addresses,
   *                                       '(regions)' for administrative regions and
   *                                       '(cities)' for localities.
   *                                       If nothing is specified, all types are returned.
   * @param {Object} componentRestrictions E.g. {country: "us"}
   */
  function requestGooglePlacesPredictions([searchQuery, types, componentRestrictions]) {
    log("requestGooglePlacesPredictions", searchQuery, types, componentRestrictions);

    autocomplete.getPlacePredictions({
      input: searchQuery,
      types: types,
      componentRestrictions: componentRestrictions,
    }, predictions => {
      predictions = predictions || []; // Default to empty list if null
      log("receiveGooglePlacesPredictions", predictions);

      ports.receiveGooglePlacesPredictions.send(predictions)
    });
  }
}

/**
 * Given a PlaceResult object, get the bounds "URL value" containing
 * north, south, east, and west coordinates.
 *
 * @param  {PlaceResult} placeResult
 * @return {String       E.g. "32.3581612957,-117.530496552,33.2894474591,-116.659830048"
 */
function getBoundsUrlValue(placeResult) {
  let bounds;

  if (placeResult.geometry && placeResult.geometry.viewport) {
    bounds = placeResult.geometry.viewport;
  } else {
    bounds = placeResult.geometry.location;
  }

  return bounds.toUrlValue(10);
}
