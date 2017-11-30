module.exports = {
  register: register,
  samplePortName: "showAuth0Modal"
};

/**
 * Subscribe the given Elm app ports to the Auth0 ports from the Elm Auth0 ports module.
 *
 * @param  {Object}   ports  Ports object from an Elm app
 * @param  {Function} log    Function to log ports for the given Elm app
 */
function register(ports, log) {
  ports.showAuth0Modal.subscribe(showAuth0Modal);

  ports.userId.send(window.__USERDATA__ && window.__USERDATA__.id || null);

  /**
   * Show the Auth0 modal
   *
   * @param {Object} options Options to send to auth0Lock.show() (Notably, flashMessage)
   *                         See: https://github.com/auth0/lock#showoptions
   */
  function showAuth0Modal(flashMessageConfig) {
    log("showAuth0Modal", flashMessageConfig);

    const options = flashMessageConfig
      ? {
          flashMessage: {
            type: flashMessageConfig.isError ? "error" : "success",
            text: flashMessageConfig.message
          }
        }
      : {};

    auth0Lock().show(options);
  }
}

/**
 * Get an Auth0Lock object configured with the current URL params
 *
 * @return {Auth0Lock}
 */
function auth0Lock() {
  return new Auth0Lock(
    $PROCESS_ENV_AUTH0_CLIENT_ID,
    $PROCESS_ENV_AUTH0_DOMAIN,
    {
      auth: {
        redirectUrl: window.location.origin + "/auth/auth0/callback",
        responseType: "code",
        params: {
          state: getToken(window.location.search),
        }
      },
      languageDictionary: {
        title: "Smart Real Estate",
      },
      socialButtonStyle: "big",
      theme: {
        logo: "https://storage.googleapis.com/sre-com-assets/images/sre-logo__107x58.png", // v10 lock config
        primaryColor: "#00b3e6",
      },
      additionalSignUpFields: [
        {
          name: "first_name",
          placeholder: "first name",
        },
        {
          name: "last_name",
          placeholder: "last name",
        },
      ],
    }
  );
}

/**
* Get the token from the query params
*
* @param {String} searchParams The search field from the window.loaction or a string that is like the search field from window.location
*/
function getToken(searchParams) {
  if (searchParams.length === 0) {
    return null;
  }

  const searchParamsFormatted =
    searchParams
      .replace("?", "")
      .split("&")
      .map(function(params) {
        return params.split("=");
      })
      .reduce(function(acc, params) {
        acc[params[0]] = params[1];
        return acc;
      }, {});

  return JSON.stringify(searchParamsFormatted) //.token;
}
