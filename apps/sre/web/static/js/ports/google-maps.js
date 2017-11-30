module.exports = {
  register: register,
  samplePortName: "createMap"
};

const { broadcast } = require("./pub-sub");
const { getNode } = require("../lib/dom");
const MapOverlay = require('../lib/map-overlay');

const maps = {};
const mapMountNodes = {};
const mapOverlays = {};

const MAP_DEFAULT_MIN_ZOOM = 5;
const MAP_DEFAULT_ZOOM = 11;
const MAP_DEFAULT_CENTER = { lat: 32.7841389982, lng: -117.0929783844 };
const MAP_DEFAULT_TYPE = "ROADMAP";
const MIN_ZOOM_TO_SHOW_LABELS = 12;

/**
 * Subscribe the given Elm app ports to all Google Maps ports from the Elm GoogleMaps port module.
 *
 * @param {Object}   ports  Ports object from an Elm app
 * @param {Function} log    Function to log ports for the given Elm app
 */
function register(ports, log) {
  ports.createMap.subscribe(createMap);
  ports.fitBounds.subscribe(fitBounds);
  ports.setCenter.subscribe(setCenter);
  ports.setZoom.subscribe(setZoom);
  ports.addPropertyMarkers.subscribe(addPropertyMarkers);
  ports.addMarkers.subscribe(addMarkers);
  ports.clearMarkers.subscribe(clearMarkers);

  if (! google) {
    throw new Error("window.google not loaded, cannot load Google Maps ports");
  }

  function createMap([selector, createMapOptions]) {
    log("createMap", selector, createMapOptions);

    const {
      center,
      zoom,
      maxZoom,
      minZoom,
      mapTypeId,
      signInControl,
      mapTypeControlPosition,
      zoomControlPosition,
      streetViewControlPosition,
      rotateControlPosition,
      disableDefaultUI,
      styles,
      scrollWheel
    } = createMapOptions;

    const mountNode = getNode(selector);

    if (!mountNode) {
      log("createMap [not found]", selector);
      return;
    }

    if (mapMountNodes[selector] && mapMountNodes[selector] === mountNode) {
      throw new Error(`Attempting to re-mount a map on a node (${selector}) with a map already mounted on it`);
    }

    mapMountNodes[selector] = mountNode;

    maps[selector] = new google.maps.Map(mountNode, {
      center: center || MAP_DEFAULT_CENTER,
      zoom: zoom === null ? MAP_DEFAULT_ZOOM : zoom,
      maxZoom: maxZoom,
      minZoom: minZoom === null ? MAP_DEFAULT_MIN_ZOOM : minZoom,
      styles: styles,
      mapTypeId: google.maps.MapTypeId[mapTypeId || MAP_DEFAULT_TYPE],
      signInControl: signInControl,
      disableDefaultUI: disableDefaultUI,
      scrollwheel: scrollWheel,

      // google.maps.ControlPosition is a dict mapping strings to ints (e.g. "TOP_RIGHT" to 3)
      mapTypeControlOptions: mapTypeControlPosition ? { position: google.maps.ControlPosition[mapTypeControlPosition] } : null,
      zoomControlOptions: zoomControlPosition ? { position: google.maps.ControlPosition[zoomControlPosition] } : null,
      streetViewControlOptions: streetViewControlPosition ? { position: google.maps.ControlPosition[streetViewControlPosition] } : null,
      rotateControlOptions: rotateControlPosition ? { position: google.maps.ControlPosition[rotateControlPosition] } : null,
    });

    ports.createMapFinished.send(selector);

    const sendEventWithBounds = event => () => {
      const bounds = maps[selector].getBounds();

      if (!bounds) {
        log(event + " port cannot be sent: map.getBounds() did not return bounds", selector);
        return;
      }

      const boundsUrlValue = bounds ? bounds.toUrlValue() : null;

      log(event, selector, boundsUrlValue);
      ports[event].send([selector, boundsUrlValue]);
    };

    maps[selector].addListener("dragend", sendEventWithBounds("dragEnd"));
    maps[selector].addListener("zoom_changed", sendEventWithBounds("zoomChanged"));
    maps[selector].addListener("idle", sendEventWithBounds("idle"));
  }

  function fitBounds([selector, latLngBounds]) {
    log("fitBounds", selector, latLngBounds);

    const map = maps[selector];

    if (!map) {
      log("fitBounds [map not found]", selector);
      return;
    }

    const [southwest, northeast] = latLngBounds;
    const bounds = new google.maps.LatLngBounds(southwest, northeast);

    map.fitBounds(bounds);
  }

  function setCenter([selector, latLng]) {
    log("setCenter", selector, latLng);

    const map = maps[selector];

    if (!map) {
      log("setCenter [map not found]", selector);
      return;
    }

    map.setCenter(latLng);
  }

  function setZoom([selector, zoom]) {
    log("setZoom", selector, zoom);

    const map = maps[selector];

    if (!map) {
      log("setZoom [map not found]", selector);
      return;
    }

    map.setZoom(zoom);
  }

  function addPropertyMarkers([selector, markerConfigs]) {
    log("addPropertyMarkers", selector, markerConfigs);

    const map = maps[selector];

    if (!map) {
      log("addPropertyMarkers [map not found]", selector);
      return;
    }

    if (mapOverlays[selector]) {
      mapOverlays[selector].setMap(null);
    }

    const showLabels = map.getZoom() >= MIN_ZOOM_TO_SHOW_LABELS;

    const markerConfigToLatLng = m => m.latLng.lat + "-" + m.latLng.lng;

    const groups = markerConfigs
      .reduce((groups, markerConfig) => {
        const key = markerConfigToLatLng(markerConfig);
        groups[key] = groups[key] || [];
        groups[key].push(markerConfig);
        return groups;
      }, {});

    const markers = objectValues(groups)
      .map(group => {
        const property = group[0];
        const label =
          showLabels
            ? (group.length > 1)
                ? `${group.length} Units`
                : formatPrice(property.price)
            : "";

        const onClick =
          (ports.receiveBroadcast)
            ? (group.length > 1)
                ? () => broadcast(log)(["groupMarkerClicked", group])
                : () => broadcast(log)(["propertyMarkerClicked", property])
            : () => null

        return {
          latLng: new google.maps.LatLng(property.latLng.lat, property.latLng.lng),
          onClick: onClick,
          label: label
        };
      });

    mapOverlays[selector] = new MapOverlay({
      map: map,
      markers: markers
    });
  }

  function addMarkers([selector, markerConfigs]) {
    log("addMarkers", selector, markerConfigs);

    const map = maps[selector];

    if (!map) {
      log("addMarkers [map not found]", selector);
      return;
    }

    if (mapOverlays[selector]) {
      mapOverlays[selector].setMap(null);
    }

    function markerConfigToOverlayMarker({ latLng, name }) {
      return {
        latLng: new google.maps.LatLng(latLng.lat, latLng.lng),
        onClick: () => broadcast(log)(["markerClicked", name])
      };
    }

    mapOverlays[selector] = new MapOverlay({
      map: map,
      markers: markerConfigs.map(markerConfigToOverlayMarker)
    });
  }

  function clearMarkers(selector) {
    log("clearMarkers", selector);

    if (!mapOverlays[selector]) {
      log("clearMarkers [no markers found]", selector);
      return;
    }

    mapOverlays[selector].setMap(null);
  }
}

function clearMaps() {
  for (map in maps) {
    delete maps[map];
  }
}

function objectValues(object) {
  const values = [];

  for (const key in object) {
    if (object.hasOwnProperty(key)) {
      values.push(object[key]);
    }
  }

  return values;
}

function formatPrice(price) {
  const priceString =
    price < 1000 ? price.toFixed(0) :
    price < 1000000 ? Math.round(price / 1000) + "k" :
    price < 1000000000 ? (Math.round(price / 100000) / 10).toFixed(1) + "m" :
    price < 1000000000000 ? (Math.round(price / 10000000) / 100).toFixed(2) + "b" :
    "∞";

  return "$" + priceString;
}
