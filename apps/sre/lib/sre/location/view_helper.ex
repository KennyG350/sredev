defmodule Sre.Location.ViewHelper do
  @moduledoc """
  Helper functions for formatting common location data.
  """

  alias Sre.UserLocation
  alias Schema.Resource.Feed

  @centerpoint_search_box_size 7 # in miles
  @feed_search_box_size 20 # in miles
  @decimals_for_url_lat_lng 10
  @meters_per_mile 1609

  def has_user_location(nil), do: false
  def has_user_location(_location) do
    true
  end

  def get_user_lat(location) do
    location.latitude
  end

  def get_user_lng(location) do
    location.longitude
  end

  def get_user_location(location) do
    if location.city && location.state do
      "#{location.city}, #{location.state}"
    else
      ""
    end
  end

  def get_user_location_bounds(%{latitude: nil}), do: ""
  def get_user_location_bounds(location) do
    [location.latitude, location.longitude]
    |> Geocalc.bounding_box(@centerpoint_search_box_size * @meters_per_mile)
    |> bounding_box_to_string()
  end

  def location_search_url(nil, _price_min, _price_max), do: "#"
  def location_search_url(%UserLocation{latitude: nil}, _price_min, _price_max), do: "#"
  def location_search_url(location, price_min, price_max)
    when is_float(price_min) and is_float(price_max)
  do
    location_search_url(location)
    <> "&price_min="
    <> :erlang.float_to_binary(price_min, decimals: 0)
    <> "&price_max="
    <> :erlang.float_to_binary(price_max, decimals: 0)
  end
  def location_search_url(%UserLocation{latitude: nil}), do: "#"
  def location_search_url(location) do
    "/properties?location="
    <> get_url_safe_user_location(location)
    <> "&bounds="
    <> get_user_location_bounds(location)
  end

  def feed_search_bounding_box(%Feed{lat: lat, lng: lng}) do
    [Decimal.to_float(lat), Decimal.to_float(lng)]
    |> Geocalc.bounding_box(@feed_search_box_size * @meters_per_mile)
    |> bounding_box_to_string()
  end

  # Return bounding box as coordinates in south,west,north,east order to match Google Maps
  defp bounding_box_to_string([
    [south, west],
    [north, east]
  ]) when is_float(north) and is_float(south) and is_float(east) and is_float(west) do
    "#{:erlang.float_to_binary(south, decimals: @decimals_for_url_lat_lng)},"
    <> "#{:erlang.float_to_binary(west, decimals: @decimals_for_url_lat_lng)},"
    <> "#{:erlang.float_to_binary(north, decimals: @decimals_for_url_lat_lng)},"
    <> "#{:erlang.float_to_binary(east, decimals: @decimals_for_url_lat_lng)}"
  end

  defp get_url_safe_user_location(location) do
    location
    |> get_user_location()
    |> String.replace(" ", "+")
  end
end
