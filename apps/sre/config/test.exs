use Mix.Config

browserstack_user = System.get_env("BROSWERSTACK_USER")
browserstack_key = System.get_env("BROSWERSTACK_KEY")

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sre, Sre.Endpoint,
  http: [port: 4001],
  host: "http://localhost",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :sre, :photo_cdn, "https://sre-qa.imgix.net/"

# Define your application's host and port (defaults to "http://localhost:4001")
config :hound,
  host: "http://#{browserstack_user}:#{browserstack_key}@hub-cloud.browserstack.com",
  port: 80,
  browser: "chrome"

config :sre,
  from_email: "noreply@sre.com",
  to_email: "qa@knledg.com"
  # photo_cdn: "https://sre-production.imgix.net/",
  # ip_location_key: "SAKB68XT85854ETM999Z"

config :sre, Sre.Mailer,
  adapter: Bamboo.TestAdapter

config :ueberauth, Ueberauth,
  providers: [
    auth0: {Ueberauth.Strategy.Auth0, [
      callback_url: "http://localhost:4001/auth/auth0/callback"
    ]}
  ]
