module.exports = {
  init: init
};

/**
 * ==== MONARCH ====
 *
 * Monarch is our simple routing solution.
 *
 * It follows the "Unix philosophy" by doing only one thing:
 * Launching Elm apps based on the URL path.
 */

const Elm = require("./elm");
const { logFor } = require("./lib/log-ports");
const monarchLog = logFor("Monarch");

let portModules;

/**
 * Initialize Monarch Elm app and wire up ports to it.
 *
 * @param {Array} portModules_  An array of port module objects with `register` and `samplePortName`
 */
function init(portModules_) {
  portModules = portModules_;

  const monarch = worker("Monarch");

  monarch.ports.worker.subscribe(worker);

  monarch.ports.workerWithFlags.subscribe(
    ([name, flags]) => worker(name, flags)
  );

  monarch.ports.embed.subscribe(
    ([name, selector]) => embed(name, selector)
  );

  monarch.ports.embedWithFlags.subscribe(
    ([name, selector, flags]) => embed(name, selector, flags)
  );

  monarch.ports.refreshBrowser.subscribe(() => {
    monarchLog("refreshBrowser");
    window.location.reload();
  });

  monarch.ports.routerLog.subscribe(message => {
    monarchLog(message);
  });
}

/**
 * Launch an Elm worker app.
 *
 * @param  {String} name  The name of the Elm app
 * @param  {Object} flags
 *
 * @throws {Error}  Elm[name].App must be an Elm module with `main` defined.
 */
function worker(name, flags) {
  if (flags) {
    monarchLog("worker " + name, flags);
  } else {
    monarchLog("worker " + name);
  }

  const App = elmApp(name);
  const application = App.worker ? App.worker(flags) : App.embed(document.createElement("div"));
  registerPorts(application.ports, name);

  return application;
}

/**
 * Embed an Elm app in the HTML document.
 *
 * @param  {String}          name     The name of the Elm app
 * @param  {String}          selector A selector for a DOM element
 * @param  {Object|Function} flags    Either a flags object or a function taking `app` and returning a flags object
 *
 * @throws {Error}  The selector must correspond to an existing DOM node.
 * @throws {Error}  Elm[name].App must be an Elm module with `main` defined.
 */
function embed(name, selector, flags) {
  if (flags) {
    monarchLog("embed " + name, selector, flags);
  } else {
    monarchLog("embed " + name, selector);
  }

  const domNode = document.querySelector(selector);

  if (!domNode) {
    throw new Error(`Elm app ${name} couldn't be launched. DOM node not found with selector ${selector}.`);
  }

  const App = elmApp(name);
  const application = App.embed(domNode, flags);
  registerPorts(application.ports, name);
}

/**
 * Return an un-launched Elm app with the given name.
 *
 * The name of the Elm app can be namespaced with a "." as such:
 *
 *   elmApp("Foo")         // Elm.Foo.App
 *   elmApp("Foo.Bar")     // Elm.Foo.Bar.App
 *   elmApp("Foo.Bar.Baz") // Elm.Foo.Bar.Baz.App
 *
 * @param  {String} name The name of an Elm app
 * @throws {Error}  Elm[name] must have been added to brunch-config.js in `plugins -> elmBrunch -> mainModules`.
 * @throws {Error}  Elm[name].App must be an Elm module with `main` defined.
 */
function elmApp(name) {
  const appContainer = name.split(".").reduce(
    (container, nameSegment) => {
      if (!container[nameSegment]) {
        throw new Error(`Elm module \`${name}.App\` not found. ` +
          "Did you add it to brunch-config.js in `plugins -> elmBrunch -> mainModules`? " +
          "Does it export a `main` function?`"
        );
      }

      return container[nameSegment];
    },
    Elm
  );

  if (!appContainer.App) {
    throw new Error(
      `Expected Elm namespace \`${name}\` to contain App module exporting \`main\`. ` +
      "Hint: Did you create `App.elm` in that folder? " +
      "Did you add it to brunch-config.js in `plugins -> elmBrunch -> mainModules`?"
    );
  }

  return appContainer.App;
}

/**
 * Register all detected ports modules on the given Elm app.
 *
 * @param {Object}   ports       Ports object from an Elm app
 * @param {Function} elmAppName  The name of the Elm app
 */
function registerPorts(ports, elmAppName) {
  const log = logFor(elmAppName);

  portModules.forEach(portModule => {
    const { register, samplePortName } = portModule;

    const throwError = errorString => {
      throw new Error(
        errorString +
        " I'm not sure which port module this is, but I found these properties exported: " +
        Object.keys(portModule).join(" ")
      );
    }

    if (!register) {
      throwError(
        "Port modules must export a `register` Function with this signature: " +
        "`register(ports, log)`."
      );
    }

    if (!samplePortName) {
      throwError(
        "Port modules must export a `samplePortName` String. It should contain the name of a " +
        "port in the given module so I know whether a given Elm app is using this port module."
      );
    }

    if (ports[samplePortName]) {
      register(ports, log);
    }
  });
}
