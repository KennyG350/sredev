defmodule ListingSearchTest do
  @moduledoc """
  Test listing search functions
  """
  use ExUnit.Case, async: true
  doctest ListingSearch

  alias ListingSearch.Search

  test "search by bedroom count" do
    results = Search.fetch(filters: %{
      bedrooms: 8
    })

    Enum.map(results, fn r ->
      assert(r.bedrooms >= 8)
    end)
  end

  test "search by bathroom count" do
    results = Search.fetch(filters: %{
      bathrooms: 8
    })

    Enum.map(results, fn r ->
      assert(r.bedrooms >= 8)
    end)
  end

  test "search by bedroom and bathroom only returns results that meet the minimum" do
    results = Search.fetch(filters: %{
      bedrooms: 8,
      bathrooms: 7
    })

    Enum.map(results, fn r ->
      assert(r.bedrooms >= 8)
      assert(r.baths >= 7)
    end)
  end

  test "search by max and min price" do
    results = Search.fetch(filters: %{
      price_max: 8_000_000,
      price_min: 7_000_000
    })

    Enum.map(results, fn r ->
      assert(r.price <= Decimal.new(8_000_000))
      assert(r.price >= Decimal.new(7_000_000))
    end)
  end

  test "search by just max price" do
    results = Search.fetch(filters: %{
      price_max: 100_000,
    })

    Enum.map(results, fn r ->
      assert(r.price <= Decimal.new(100_000))
    end)
  end

  test "search by just min price" do
    results = Search.fetch(filters: %{
      price_min: 10_000_000,
    })

    Enum.map(results, fn r ->
      assert(r.price >= Decimal.new(10_000_000))
    end)
  end

  test "search by bounding box" do
    results = Search.fetch(filters: %{
      bounds: "32.7932689208,-117.1889664364,32.8162643557,-117.1657063199"
    })

    Enum.map(results, fn r ->
      assert(Decimal.to_float(r.latitude) >= 32.7932689208)
      assert(Decimal.to_float(r.latitude) <= 32.8162643557)
      assert(Decimal.to_float(r.longitude) >= -117.1889664364)
      assert(Decimal.to_float(r.longitude) <= -117.1657063199)
    end)
  end

  test "search by lat/lng" do
    all_listings = Search.fetch()
    first_listing = Enum.at(all_listings, 0)
    lat_lng_results = Search.fetch(filters: %{
      bounds: to_string(first_listing.latitude) <> "," <> to_string(first_listing.longitude)
    })

    Enum.map(lat_lng_results, fn r ->
      assert(r.latitude === first_listing.latitude)
      assert(r.longitude === first_listing.longitude)
    end)
  end

  test "default pagination" do
    results = Search.fetch()

    assert(Enum.count(results) === 20)
  end

  test "pagination" do
    results1 = Search.fetch(page: 1)
    results2 = Search.fetch(page: 2)

    assert(Enum.at(results1, 0).url !== Enum.at(results2, 0).url)
  end

  test "custom per_page count" do
    results = Search.fetch(page: 1, per_page: 30)

    assert(Enum.count(results) === 30)
  end

  test "sort by highest price" do
    results = Search.fetch(order_by: "highest_price")

    Enum.reduce(results, fn(result, last_result) ->
      assert(result.price <= last_result.price)

      result
    end)
  end

  test "sort by lowest price" do
    results = Search.fetch(order_by: "lowest_price")

    Enum.reduce(results, fn(result, last_result) ->
      assert(result.price >= last_result.price)

      result
    end)
  end

  test "default sort is original_entry_timestamp" do
    results = Search.fetch()

    Enum.reduce(results, fn(result, last_result) ->
      assert(result.original_entry_timestamp <= last_result.original_entry_timestamp)

      result
    end)
  end

  test "results doesn't include photos by default" do
    results = Search.fetch()

    first_item = Enum.at(results, 0)

    assert(first_item.photos === %Ecto.Association.NotLoaded{
      __cardinality__: :many,
      __field__: :photos,
      __owner__: Schema.Resource.Listing
    })
  end

  test "results include photos when they are preloaded" do
    results = Search.fetch(preload: [:photos])

    first_item = Enum.at(results, 0)

    assert(Enum.count(first_item.photos) > 0)
  end

  test "select by url slug" do
    listing = Search.fetch_by_url("516-halela-kailua-hi-96734-a9f3cc05", nil)
    assert(listing.url === "516-halela-kailua-hi-96734-a9f3cc05")
  end

  test "select by url includes photos" do
    listing = Search.fetch_by_url("516-halela-kailua-hi-96734-a9f3cc05", nil)
    assert(Enum.count(listing.photos) > 0)
  end

end
