/**
 * The Monarch router will automatically wire up all port modules added here
 * to any Elm app that is launched.
 *
 * All port modules should define the following:
 *   `register`        A function with the signature `register(ports, log)` that wires up all ports
 *   `samplePortName`  The name of one of the ports in the module, so that Monarch can detect
 *                     whether a given Elm app uses those ports
 */
module.exports = [
  require("./ports/analytics"),
  require("./ports/auth"),
  require("./ports/dom"),
  require("./ports/google-maps"),
  require("./ports/google-places"),
  require("./ports/local-storage"),
  require("./ports/pub-sub"),
  require("./ports/routing"),
  require("./ports/walk-score"),
  require("./ports/websocket"),
];
