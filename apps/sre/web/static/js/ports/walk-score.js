module.exports = {
  register: register,
  samplePortName: "showWalkScoreTile"
};

/**
 * Register WalkScore ports for the given Elm app.
 *
 * @param  {Object}   ports  Ports object from an Elm app
 * @param  {Function} log    Function to log ports for the given Elm app
 */
function register(ports, log) {
  ports.showWalkScoreTile.subscribe(showWalkScoreTile);

  function showWalkScoreTile([lat, lon]) {
    log("showWalkScoreTile", lat, lon);

    // Only load once
    if (!window.ws_wsid) {
      // Walkscore's javascript is terrible and requires all these to be globals. :(
      window.ws_wsid = "gd5dc031997164dc1afd79519411e0dcf";
      window.ws_transit_score = "true";
      window.ws_industry_type = "residential";
      window.ws_hide_scores_below = "100";
      window.ws_hide_bigger_map = "true";
      window.ws_width = "100%";
      window.ws_height = "800";
      window.ws_layout = "none";
      window.ws_hide_footer = "true";
      window.ws_commute = "true";
      window.ws_transit_score = "true";
      window.ws_map_modules = "default";
      window.ws_no_link_info_bubbles = "true";
      window.ws_commute = "true";
      window.ws_no_link_score_description = "true";
    }

    window.ws_lat = lat;
    window.ws_lon = lon;

    loadScriptTag("https://www.walkscore.com/tile/show-walkscore-tile.php");
  }
}

function loadScriptTag(src) {
  const scriptTag = document.createElement('script');
  scriptTag.src = src;
  scriptTag.async = true;
  document.head.appendChild(scriptTag);
};
