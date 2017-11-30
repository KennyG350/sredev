use Mix.Config

config :listing_search, ListingSearch.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("LISTING_SEARCH_DATABASE_URL"),
  pool_size: "100",
  ssl: true
