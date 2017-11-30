# ListingSearch

An application listing search queries.

### Example Usage

```
# Filters and order by highest price
listings = ListingSearch.Search.fetch(
  filters: %{
    bounds: "32.6818115751,-117.3293096182,33.0494851749,-116.9997197744",
    bedrooms: 4,
    bathrooms: 2,
    maxPrice: 50_000,
    minPrice: 1_000
  },
  orderBy: :highestPrice
)

# Limit and offset (can be used for pagination)
listings = ListingSearch.Search.fetch(
  filters: %{
    bounds: "32.6818115751,-117.3293096182,33.0494851749,-116.9997197744"
  },
  limit: 25,
  offset: 100
)

# Count listings
num_listings = ListingSearch.Search.count(
  filters: %{
    bounds: "32.6818115751,-117.3293096182,33.0494851749,-116.9997197744",
    bedrooms: 4,
    bathrooms: 2,
    maxPrice: 50_000,
    minPrice: 1_000
  }
)

# Custom select (defaults to returning all fields)
map_listings = ListingSearch.Search.fetch(
  filters: %{
    bounds: "32.6818115751,-117.3293096182,33.0494851749,-116.9997197744",
  },
  orderBy: :highestPrice,
  select: [:url, :latitude :longitude]
)

# Select by url slug
listing = ListingSearch.Search.fetch(url: "1009-1903-kapiolani-honolulu-hi-96814-fee81dc3")

```
