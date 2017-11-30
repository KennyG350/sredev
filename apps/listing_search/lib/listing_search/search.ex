defmodule ListingSearch.Search do
  @moduledoc """
  Functions for requesting listing data.
  """

  require Ecto.Query
  alias Ecto.Query

  alias ListingSearch.{
    Search,
    Repo
  }

  alias Schema.Resource.{
    Feed,
    Group,
    Listing
  }

  @per_page_default Application.get_env(:listing_search, :default_listings_per_page)
  @square_feet_per_acre 43_560
  @favorites_group_name "Favorites"

  @doc """
  Returns listings that match the given filters.

  Example:

  %ListingSearch.Options{

  }

  listings = ListingSearch.Search.fetch(
    filters: %{
      :bounds => "32.6818115751,-117.3293096182,33.0494851749,-116.9997197744",
      :bedrooms => 4,
      :bathrooms => 2,
      :price_max => 500_000,
      :price_min => 50_000
    },
    order_by: :highestPrice
  )
  """
  def fetch(params \\ []) do
    Listing
    |> custom_select(params[:select])
    |> preload(params[:preload])
    |> default_filters
    |> optional_filters(params[:filters])
    |> order_by(params[:order_by])
    |> apply_pagination(params[:page], params[:per_page])
    |> get_only_syndicating
    |> favorited_by(params[:user_id])
    |> Repo.all
  end

  def fetch_by_id(id, _params \\ []) do
    Listing
    |> Query.preload([:photos, feed: :feed_connection])
    |> Repo.get(id)
  end

  def fetch_by_city_and_state(nil, nil), do: []
  def fetch_by_city_and_state(city, state) do
    Listing
    |> listing_by_city(city)
    |> listing_by_state(state)
    |> default_filters
    |> get_only_syndicating
    |> Query.limit(6)
    |> Query.preload([:photos, feed: :feed_connection])
    |> Repo.all
  end

  def fetch_by_city_state_and_price(nil, nil, _price_min, _price_max), do: []
  def fetch_by_city_state_and_price(_city, _state, nil, _price_max), do: []
  def fetch_by_city_state_and_price(_city, _state, _price_min, nil), do: []
  def fetch_by_city_state_and_price(city, state, price_min, price_max) do
    Listing
    |> listing_by_city(city)
    |> listing_by_state(state)
    |> default_filters
    |> get_only_syndicating
    |> optional_filters(%{price_min: price_min, price_max: price_max})
    |> Query.limit(6)
    |> Query.preload([:photos, feed: :feed_connection])
    |> Repo.all
  end

  def city_state_and_price_count(nil, nil, _price_min, _price_max), do: 0
  def city_state_and_price_count(_city, _state, nil, _price_max), do: 0
  def city_state_and_price_count(_city, _state, _price_min, nil), do: 0
  def city_state_and_price_count(city, state, price_min, price_max) do
    Listing
    |> Query.select([p], count(p.id))
    |> listing_by_city(city)
    |> listing_by_state(state)
    |> default_filters
    |> get_only_syndicating
    |> optional_filters(%{price_min: price_min, price_max: price_max})
    |> Repo.one
  end

  @doc """
  Returns a count of listings for the given filters.

  Example:

  count = ListingSearch.Search.count(
    filters: %{
      :bounds => "32.6818115751,-117.3293096182,33.0494851749,-116.9997197744",
      :bedrooms => 4
    }
  )
  """
  def count(params \\ []) do
    Listing
    |> Query.select([p], count(p.id))
    |> default_filters
    |> optional_filters(params[:filters])
    |> get_only_syndicating
    |> Repo.one
  end

  @doc """
  Fetch one record by url slug. The returned record will include related photo records.

  Example:

  listing = ListingSearch.Search.fetch_by_url("1152-w-6th-pomona-ca-91766-7a2b461b")
  """
  def fetch_by_url(url, user_id) do
    Listing
    |> Query.where([p], p.url == ^url)
    |> Query.preload([:photos, feed: :feed_connection])
    |> favorited_by(user_id)
    |> Repo.one
  end

  def default_filters(query) do
    query
    |> Query.where([p], p.status == "Active")
    |> Query.where([p], p.is_valid == true)
    |> Query.where([p], p.type != "Other")
    |> Query.where([p], not(is_nil(p.type)))
    |> Query.where([p], not(is_nil(p.price)))
    |> Query.where([p], not(is_nil(p.latitude)))
    |> Query.where([p], not(is_nil(p.longitude)))
    |> Query.where([p], not(is_nil(p.photo_sync_date) and not(is_nil(p.photos_last_updated))))
  end

  def optional_filter({:location, _value}, query) do
    # @todo: support location based lookups (MLS number, zip code, etc)?
    query
  end
  def optional_filter({:type, value}, query) do
    Query.where(query, [p], p.type == ^value)
  end

  def optional_filter({:bedrooms, value}, query) do
    Query.where(query, [p], p.bedrooms >= ^value)
  end

  def optional_filter({:bathrooms, value}, query) do
    Query.where(query, [p], p.baths >= ^value)
  end

  def optional_filter({:price_max, nil}, query), do: query
  def optional_filter({:price_max, value}, query) do
    Query.where(query, [p], fragment("price::numeric") <= ^value)
  end

  def optional_filter({:price_min, nil}, query), do: query
  def optional_filter({:price_min, value}, query) do
    Query.where(query, [p], fragment("price::numeric") >= ^value)
  end

  def optional_filter({:lot_size_min, acres}, query) do
    lot_square_footage = @square_feet_per_acre * acres
    Query.where(query, [p], p.square_footage >= ^lot_square_footage)
  end

  def optional_filter({:home_size_min, value}, query) do
    Query.where(query, [p], p.living_area >= ^value)
  end

  def optional_filter({:year_built_min, value}, query) do
    year_built = to_string value
    Query.where(query, [p], p.year_built >= ^year_built)
  end

  def optional_filter({:exclude_house, _}, query) do
    query
    |> Query.where([p], p.type != "Single Family")
  end

  def optional_filter({:exclude_townhouse, _}, query) do
    query
    |> Query.where([p], p.type != "Townhome")
  end

  def optional_filter({:exclude_condo, _}, query) do
    query
    |> Query.where([p], p.type != "Condo")
  end

  def optional_filter({:bounds, value}, query) do
    bounds = bounds(value)

    bounds
    |> Enum.count
    |> case do
      2 ->
        query
          |> Query.where([p], p.latitude == ^Enum.at(bounds, 0, 0))
          |> Query.where([p], p.longitude == ^Enum.at(bounds, 1, 0))
      4 ->
        query
        |> Query.where([p], fragment(
          "ST_WITHIN(geo, ST_MakeEnvelope(?, ?, ?, ?, 4326))",
          ^Enum.at(bounds, 1, 0),
          ^Enum.at(bounds, 0, 0),
          ^Enum.at(bounds, 3, 0),
          ^Enum.at(bounds, 2, 0)
        ))
      _ ->
        query
    end
  end

  defp bounds(value) do
    value
    |> String.split(",")
    |> Enum.reduce([], fn(val, acc) ->
      case Float.parse(val) do
        {val, _} -> acc ++ [val]
        _ -> acc
      end
    end)
  end

  defp apply_pagination(query, page, nil) do apply_pagination(query, page, @per_page_default) end
  defp apply_pagination(query, page, per_page) when is_binary per_page  do
    query
    |> apply_pagination(page, String.to_integer(per_page))
  end
  defp apply_pagination(query, page, per_page) do
    page = page || 1
    offset = per_page * (page - 1)

    query
    |> Query.limit(^per_page)
    |> Query.offset(^offset)
  end

  defp preload(query, nil) do query end
  defp preload(query, preloads) do
    Query.preload(query, ^preloads)
  end

  defp custom_select(query, nil) do query end
  defp custom_select(query, fields) do
    Query.select(query, ^fields)
  end

  defp optional_filters(query, nil) do query end
  defp optional_filters(query, filters) do
    filters
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.reduce(query, &Search.optional_filter(&1, &2))
  end

  defp order_by(query, order_by) do
    case order_by do
      "distance" ->
        query # @todo: make this work :)
      "highest_price" ->
        Query.order_by(query, [desc: fragment("price::numeric")])
      "lowest_price" ->
        Query.order_by(query, [asc: fragment("price::numeric")])
      "recent" ->
        Query.order_by(query, [desc: :original_entry_timestamp])
      _ ->
        Query.order_by(query, [desc: :original_entry_timestamp])
    end
  end

  defp get_only_syndicating(query) do
    if System.get_env("IGNORE_SYNDICATION_SETTING") == "true" do
      query
    else
      query
      |> Query.join(:inner, [listing], f in Feed, listing.feed_id == f.id and f.is_syndicating == true)
    end
  end

  defp favorited_by(query, nil), do: query
  defp favorited_by(query, user_id) do
    query
    |> Query.preload([groups: ^preload_groups_for_user(user_id)])
  end

  defp preload_groups_for_user(user_id) do
    Query.from g in Group,
      where: g.name == @favorites_group_name,
      where: g.user_id == ^user_id
  end

  defp listing_by_city(query, nil), do: query
  defp listing_by_city(query, city), do: Query.where(query, [l], l.city == ^city)

  defp listing_by_state(query, nil), do: query
  defp listing_by_state(query, state), do: Query.where(query, [l], l.state == ^state)
end
