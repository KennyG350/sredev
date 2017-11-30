defmodule Sre.PropertyApiController do
  use Sre.Web, :controller

  alias ListingSearch.{Search, Filters}
  alias Sre.Listing.ViewHelper

  def index(conn, params) do
    filters = Filters.valid_filters(params)

    listings =
      Search.fetch(
        filters: filters,
        order_by: params["sort"],
        preload: [:photos],
        per_page: params["per_page"]
      )

    render conn, "search.json", data: %{records: format_listings(listings), total: Search.count filters: filters}
  end

  def show(conn, %{"id" => id}) do
    listing = Search.fetch_by_id id
    photos = ViewHelper.format_photo_url listing.photos

    listing = %{listing | photos: photos}

    case listing.feed.feed_connection.logo_path do
      nil ->
        render conn, "show.json", data: listing

      value ->
        render conn, "show.json", data: put_in(listing.feed.feed_connection.logo_path, ViewHelper.prepend_cdn_to_path(value))
    end
  end

  defp format_listings(listings) do
    listings
    |> Enum.map(fn listing ->
        photos =
          listing.photos
          |> ViewHelper.format_photo_url

        %{listing | photos: photos}
       end)
    |> Enum.map(&Map.drop(&1, [:feed]))
  end
end
