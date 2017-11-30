module.exports = {
  register: register,
  samplePortName: "broadcast",
  clearApps: clearApps,
  broadcast: broadcast,
  broadcastWithoutPayload: broadcastWithoutPayload
};

let portsObjects = []; // Holds ports objects; should be cleared out via `clearApps` when routing

/**
 * Register PubSub ports for the given Elm app.
 *
 * @param  {Object}   ports  Ports object from an Elm app
 * @param  {Function} log    Function to log ports for the given Elm app
 */
function register(ports, log) {
  portsObjects.push(ports);
  ports.broadcast.subscribe(broadcast(log));
  ports.broadcastWithoutPayload.subscribe(broadcastWithoutPayload(log));
}

/**
 * Remove all elm apps from `apps` in order to allow garbage collecting and
 * prevent memory leaks.
 *
 * (To be called when routing.)
 */
function clearApps() {
  portsObjects = [];
}

/**
 * Send a PubSub message to every Elm app registered.
 *
 * @param  {String}       message The name of the message being sent
 * @param  {Serializable} payload The payload being sent with the message
 */
function broadcast(log) {
  return ([message, payload]) => {
    log("broadcast", message, payload);

    portsObjects.forEach(ports => {
      if (ports.receiveBroadcast) {
        ports.receiveBroadcast.send([message, payload]);
      }
    });
  };
}

/**
 * Send a PubSub message to every Elm app registered -- without a payload.
 *
 * @param  {String} message The name of the message being sent
 */
function broadcastWithoutPayload(log) {
  return (message) => {
    log("broadcastWithoutPayload", message);

    portsObjects.forEach(ports => {
      if (ports.receiveBroadcast) {
        ports.receiveBroadcast.send([message, null]);
      }
    });
  };
}
