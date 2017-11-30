use Mix.Config

config :schema, Schema.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: "100",
  ssl: if System.get_env("DATABASE_USE_SSL") === "true", do: true, else: false
