module.exports = {
  register: register,
  samplePortName: "websocketSend"
};

const uuid = require("uuid");
const { Socket } = require("phoenix");

const socket = new Socket("/socket");
const userId = window.__USERDATA__ && window.__USERDATA__.id ? window.__USERDATA__.id : uuid.v4();
const channels = {};

// Connect to the socket
socket.connect();
socket.onOpen(() => {});

/**
 * Register Websocket ports for the given Elm app.
 *
 * @param  {Object}   ports  Ports object from an Elm app
 * @param  {Function} log    Function to log ports for the given Elm app
 */
function register(ports, log) {
  ports.websocketSend.subscribe(websocketSend);
  ports.websocketListen.subscribe(websocketListen);

  /**
   * Send a Websocket message.
   *
   * @param  {String} topic   The channel topic (e.g. "messages")
   * @param  {String} event   The event (e.g. "new:message")
   * @param  {Object} payload The payload to send along with the message
   */
  function websocketSend([topic, event, payload]) {
    ensureChannelJoined(topic);

    log("websocketSend", topic, event, payload);
    channels[topic].push(event, payload);
  }

  /**
   * Set up the Elm app to listen to the given channel for messages of the given topic.
   * When received, forward them to the Elm app via the `receive` port.
   *
   * @param  {String} topic The channel topic (e.g. "messages")
   * @param  {String} event The event to listen for (e.g. "new:message")
   */
  function websocketListen([topic, event]) {
    ensureChannelJoined(topic);

    channels[topic].on(event, payload => {
      log("websocketReceive", topic, event, payload);
      ports.websocketReceive.send([topic, event, payload]);
    });
  }

  /**
   * Ensure the given channel (topic) has been joined.
   *
   * @param  {String} topic Name of the Phoenix channel
   */
  function ensureChannelJoined(topic) {
    if (! channels[topic]) {
      channels[topic] = socket.channel(qualifiedTopic(topic));
      channels[topic].join();

      log("Joined channel", qualifiedTopic(topic));
    }
  }
}

/**
 * Suffix the given topic string with the unique userId.
 *
 * @param  {String} topic The non-unique topic name (e.g. "messages")
 * @return {String}       A unique version of the topic name (e.g. "messages:87AI-KJL4TJ-HKD98F87-6ASD8F5")
 */
function qualifiedTopic(topic) {
  return topic + ":" + userId;
}
