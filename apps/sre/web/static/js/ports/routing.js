module.exports = {
  register: register,
  samplePortName: "urlUpdate"
};

const portsObjects = [];

function register(ports, log) {
  portsObjects.push(ports);

  ports.broadcastUrlUpdate.subscribe(broadcastUrlUpdate);

  function broadcastUrlUpdate(location) {
    log("broadcastUrlUpdate", location);
    // There is an issue with serializing Location records;
    // `username`, `password`, `origin`, and `hash` often become `undefined`
    // (`origin` specifically in IE10)
    location.username = location.username || "";
    location.password = location.password || "";
    location.origin = location.origin || "";

    log("urlUpdate", location);
    portsObjects.forEach(ports => {
      if (ports.urlUpdate) {
        ports.urlUpdate.send(location);
      }
    });
  }
}
