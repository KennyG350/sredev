const brunchConfig = require("../brunch-config");
const config = brunchConfig.config.plugins.elmBrunch;
const exec = require("child_process").exec;

function elmMake(options) {
  const debug = options && options.debug;

  exec(
    `cd ${config.elmFolder} && ../../node_modules/elm/binwrappers/elm-make ${config.mainModules} ${debug ? "--debug" : ""} --yes --output=${config.outputFolder}/${config.outputFile} ${config.makeParameters.join(" ")}`,
    function(error, stdout, stderr) {
      console.log(stdout);
      console.log(stderr);
    }
  );
}

module.exports = elmMake;
