/**
 * APP DEPENDENCIES
 *
 * Note: Ensure that all dependencies are included in brunch-config.js in "config.paths.watched"
 */
require("phoenix_html");

/**
 * INITIALIZE MONARCH ROUTER
 */
const ports = require("./ports");
const monarch = require("./monarch");
monarch.init(ports);

/**
 * PORTS DEBUGGING
 *
 * Note: Only works on development environment.
 */
function setupPortsDebugging() {
  const { debug } = require("./lib/log-ports");

  // From the console in development environment: `logPorts()` / `logPorts("addClass", "GeoSuggest")`
  window.logPorts = debug;

  if ($PROCESS_ENV_NODE_ENV !== "production") {
    // Broadcast PubSub messages from the console:
    // window.broadcast(["listingClicked", "7010-el-camino..."]);
    const { broadcast } = require("./ports/pub-sub");
    window.broadcast = broadcast(() => null);
  }

  // Or uncomment one of the below lines to achieve various debugging behavior.

  // debug(); // Log all ports activity in the console.
  // debug("addClass", "setCssProperty"); // Log ONLY "addClass" and "setCssProperty" ports
  // debug("GeoSuggest", "addClass"); // Log "addClass" ports plus all ports to/from `GeoSuggest` app
}

setupPortsDebugging();
