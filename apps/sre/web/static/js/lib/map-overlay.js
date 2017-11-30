module.exports = MapOverlay;

const { addClass } = require('./dom');

// Expects markers to be an array of objects containing `latLng` (an actual google.maps.LatLng) and `label` and `onClick`
// Inspired by http://nickjohnson.com/b/google-maps-v3-how-to-quickly-add-many-markers
function MapOverlay({ map, markers }) {
  this.setMap(map);
  this.markers = markers;
  this.markerLayer = document.createElement("div");

  this.markerLayer.addEventListener("mousedown", () => this.dragging = false);
  this.markerLayer.addEventListener("mousemove", () => this.dragging = true);
}

MapOverlay.prototype = new google.maps.OverlayView();

MapOverlay.prototype.onAdd = function() {
  const pane = this.getPanes().overlayImage;

  pane.append(this.markerLayer);
};

MapOverlay.prototype.draw = function() {
  const projection = this.getProjection();
  const zoom = this.getMap().getZoom();
  const documentFragment = document.createDocumentFragment();

  // Remove all children
  const children = this.markerLayer.children;
  for (var i = children.length - 1; i > -1; i--) {
    this.markerLayer.removeChild(this.markerLayer.children[i]);
  }

  this.markers.forEach(marker => {
    const {latLng, label, onClick} = marker;
    const position = projection.fromLatLngToDivPixel(latLng);
    const markerElement = document.createElement("div");
    addClass("map-pin")(markerElement);

    markerElement.style.top = position.y + "px";
    markerElement.style.left = position.x + "px";

    if (label) {
      markerElement.innerHTML = `<span class="map-pin__label">${label}</span>`;
    }

    markerElement.addEventListener("click", event => {
      // Without manually tracking whether we're dragging, the user couldn't drag over a pin
      // without inadvertently triggering a click.
      // See http://stackoverflow.com/q/27504500 for an explanation.
      if (this.dragging) {
        return;
      }

      onClick(event);
    });

    documentFragment.appendChild(markerElement);
  });

  this.markerLayer.appendChild(documentFragment);
};

MapOverlay.prototype.onRemove = function() {
  this.markerLayer.parentNode.removeChild(this.markerLayer);
  this.markerLayer = null; // Collect the garbage, V8!
};

MapOverlay.prototype.hide = function() {
  if (this.element) {
    this.element.style.visibility = "hidden";
  }
};

MapOverlay.prototype.show = function() {
  if (this.element) {
    this.element.style.visibility = "visible";
  }
};

MapOverlay.prototype.toggle = function() {
  if (this.element) {
    if (this.element.style.visibility === "hidden") {
      this.show();
    } else {
      this.hide();
    }
  }
}

MapOverlay.prototype.toggleDOM = function() {
  if (this.getMap()) {
    this.setMap(null); // Calls OverlayView.onRemove()
  } else {
    this.setMap(this.map);
  }
}
