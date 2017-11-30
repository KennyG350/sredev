# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :sre, Sre.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BwCOzSykkzp1eyI6aNgwqd/8B6AlYIoGQ7GvxIr9aTLUx4CvhifuPY3sBJbeGWLi",
  render_errors: [view: Sre.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Sre.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :rollbax,
  access_token: "3d9e75b8724e494da0c202b6b7cd1f7f",
  environment: "#{Mix.env}"

config :sre,
  ecto_repos: []

config :sre,
  office_phone_numbers: %{
    ca: "8582014272",
    hi: "8085184814",
    az: "4807710636",
    wi: "4142061406",
    default: "8448563040"
  },
  listings_per_page_per_view: [ # table view vs card view
    table: 50,
    homepage: 6,
    card: 20,
  ],
  state_emails: %{
    ca: "sandiego@sre.com",
    az: "arizona@sre.com",
    hi: "info@sre.com"
  }

config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: System.get_env("AUTH0_DOMAIN"),
  client_id: System.get_env("AUTH0_CLIENT_ID"),
  client_secret: System.get_env("AUTH0_CLIENT_SECRET")

config :geolix,
  databases: [
    {:city, Path.expand("GeoIP2-City.mmdb")}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
