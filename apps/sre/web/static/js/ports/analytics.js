module.exports = {
  register: register,
  samplePortName: "gaPageView"
};

/**
 * Subscribe the given Elm app ports to the Analytics ports from the Elm AnalyticsPorts module.
 *
 * @param  {Object}   ports  Ports object from an Elm app
 * @param  {Function} log    Function to log ports for the given Elm app
 */
function register(ports, log) {
  ports.gaPageView.subscribe(gaPageView);

  /**
   * Send a pageview to Google Analytics.
   *
   * @param  {String} pathname The URL path, e.g. "/foo/bar"
   * @param  {String} title    The title of the new page
   */
  function gaPageView([pathname, title]) {
    log("gaPageView", pathname, title);

    if (typeof window.ga === "function") {
      window.ga("set", {
        page: pathname,
        title: title,
      });

      window.ga("send", "pageview");
    }
  }
}
