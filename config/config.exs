# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# By default, the umbrella project as well as each child
# application will require this configuration file, ensuring
# they all use the same configuration. While one could
# configure all applications here, we prefer to delegate
# back to each application for organization purposes.
import_config "../apps/*/config/config.exs"

# Sample configuration (overrides the imported configuration above):
#
#     config :logger, :console,
#       level: :info,
#       format: "$date $time [$level] $metadata$message\n",
#       metadata: [:user_id]

# Show warnings if environment variables are missing
[
  "AUTH0_DOMAIN",
  "AUTH0_CLIENT_ID",
  "AUTH0_CLIENT_SECRET",
  "AUTH_UPDATE_USER_TOKEN",
  "DATABASE_URL",
  "LISTING_SEARCH_DATABASE_URL",
]
|> Enum.each(fn env_var ->
  if is_nil(System.get_env(env_var)), do: IO.warn "Missing environment variable " <> env_var
end)
