const fs = require("fs");
const brunchConfig = require("../brunch-config");
const config = brunchConfig.config.plugins.elmBrunch;
const elmMake = require("./elm-make-command");

fs.watch(config.elmFolder, {recursive: true}, elmMake);
