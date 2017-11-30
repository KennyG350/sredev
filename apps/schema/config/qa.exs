use Mix.Config

config :schema, Schema.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: "50",
  ssl: true
