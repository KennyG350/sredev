use Mix.Config

config :listing_search, ListingSearch.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("LISTING_SEARCH_DATABASE_URL"),
  pool: Ecto.Adapters.SQL.Sandbox
