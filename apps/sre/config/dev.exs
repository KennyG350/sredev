use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :sre, Sre.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "./scripts/elm-make.js",
      cd: Path.expand("../", __DIR__)
    ],
    node: [
      "node_modules/brunch/bin/brunch", "watch", "--stdin",
      cd: Path.expand("../", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :sre, Sre.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/ui_components/.*(scss|eex|ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

config :sre,
  photo_cdn: "https://sre-qa.imgix.net/",
  from_email: "qa+info@knledg.com",
  to_email: "qa+info@knledg.com",
  ip_location_key: "SAKB68XT85854ETM999Z",
  office_emails: %{
    ca: "qa+sandiego@knledg.com",
    hi: "qa+hawaii@knledg.com",
    az: "qa+arizona@knledg.com",
  }

config :ueberauth, Ueberauth,
  providers: [
    auth0: {Ueberauth.Strategy.Auth0, [
      callback_url: "http://localhost:4000/auth/auth0/callback"
    ]}
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# We configure the Rollbax.Logger backend.
config :logger, Rollbax.Logger,
  level: :error

config :rollbax,
  enabled: false

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

config :sre, Sre.Mailer,
  adapter: Bamboo.LocalAdapter

config :sre,
  password_reset_link: "http://localhost:4000/change_password?token="
