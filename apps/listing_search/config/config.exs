use Mix.Config

config :listing_search,
  ecto_repos: [ListingSearch.Repo],
  default_listings_per_page: 20

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
