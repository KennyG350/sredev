exports.config = {
  files: {
    javascripts: {
      joinTo: "js/app.js",
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["web/static/css/app.css"], // concat app.css last
      },
    },
  },

  conventions: {
  // This option sets where we should place non-css and non-js assets in.
  // By default, we set this to "/web/static/assets". Files in this directory
  // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/,
  },

  // Phoenix paths configuration
  paths: {
  // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static",
      "web/ui_components",
      "web/templates",
    ],

  // Where to compile files to
    public: "priv/static",
  },

// Configure your plugins
  plugins: {
    postcss: {
      processors: [
        require("autoprefixer")(["last 8 versions"]),
      ],
    },
    presets: ["es2015", "stage-2"],
    babel: {
    // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/],
    },
    sass: {
      mode: "native",
      debug: "debug",
      options: {
        includePaths: ["web/ui_components", "web/templates"],
      },
    },
    elmBrunch: {
      elmFolder: "web/elm",
      mainModules: [
          "BuyCalculator",
          "BuyCalculator/GeoSuggest",
          "BuyCalculator/Label",
          "ContactForm",
          "DisplayContactForm",
          "FeedMaps",
          "Filters",
          "Filters/PriceRange",
          "Filters/PropertyType",
          "Filters/RangeSlider",
          "Filters/Room",
          "FiltersMenu",
          "GeoSuggest",
          "HandleInviteToken",
          "HandleLoginError",
          "ImageSliderAspectRatio",
          "ListingDetailsModal",
          "ListingFavoriteButton",
          "ListingList",
          "LoginClickHandler",
          "MobileMenu",
          "MultiUnitList",
          "PreventDoubleUrlEncoding",
          "PropertyHeroImageSlider",
          "PropertyHeroMap",
          "PropertyHeroViewSwitcher",
          "SaveSearch",
          "SearchDispatcher",
          "SearchMap",
          "SearchSort",
          "SearchViewSwitcher",
          "SellCalculator",
          "Slider",
          "UserActivityWorker",
          "WalkScore",
        ].map(function(appName) {
          return "apps/" + appName + "/App.elm";
        }).concat(["routes/Monarch/App.elm"])
        .join(" "),
      outputFolder: "../static/js",
      outputFile: "elm.js",
      makeParameters: ["--warn"],
    },
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/main"],
    },
  },
  npm: {
    enabled: true,
  },
};