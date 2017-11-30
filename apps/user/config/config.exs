use Mix.Config

config :user, ecto_repos: [Schema.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

config :user,
  auth_domain: System.get_env("AUTH0_DOMAIN"),
  client_id: System.get_env("AUTH0_CLIENT_ID"),
  client_secret: System.get_env("AUTH0_CLIENT_SECRET"),
  client_user_jwt: System.get_env("AUTH_UPDATE_USER_TOKEN")

import_config "#{Mix.env}.exs"
