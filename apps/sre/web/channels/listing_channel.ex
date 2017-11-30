defmodule Sre.ListingChannel do
  use Phoenix.Channel

  alias ListingSearch.{
    BadInputError,
    Filters,
    Search
  }

  alias Phoenix.View
  alias GreatSchools.Query

  alias User.Search, as: UserSearch

  alias Sre.{
    Channels,
    Listing.ViewHelper,
    UI.Property.List.CardList,
    UI.Property.List.TableList,
    UI.Property.List.HomepageList
  }

  def join("listing_list:" <> _user_id, _message, socket) do
    {:ok, socket}
  end

  def join("map:" <> _user_id, _message, socket) do
    {:ok, socket}
  end

  def join("listing_details:" <> _user_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("request_listing_list", message, socket) do
    user_id = Channels.get_user_id(socket)
    page = get_page_number(message)
    search_view = ViewHelper.get_search_view(message["view"])
    filters = Filters.valid_filters(message["filters"])

    saved_search =
      case user_id do
        {:ok, user_id} ->
          filters
          |> UserSearch.hash_search_params
          |> UserSearch.get_user_search_hash(user_id)

        {:error, _} ->
          nil
      end

    listings = Search.fetch(
      # Note: DO NOT preload :groups or else favorites from OTHER PEOPLE will show
      preload: [:photos, feed: :feed_connection],
      page: page,
      filters: filters,
      order_by: message["sort"],
      per_page: Application.get_env(:sre, :listings_per_page_per_view)[search_view],
      user_id: get_user_id(socket)
    )

    view = View.render_to_string(
      search_view_module(search_view),
      search_view_template(search_view),
      [
        listings: listings,
        current_page: page,
        total_results: Search.count(filters: filters)
      ]
    )

    push socket, "receive_listing_list", %{
      view: view,
      page: page,
      total_results: Search.count(filters: filters),
      saved_search: saved_search && %{name: saved_search.name, id: saved_search.id}
    }
    {:noreply, socket}
  end

  def handle_in("request_map_data", message, socket) do
    map_fields = [:url, :latitude, :longitude, :price]
    filters = Filters.valid_filters(message["filters"])

    listings = [select: map_fields, per_page: 500, filters: filters]
    |> Search.fetch
    |> Enum.map(&Map.take(&1, map_fields))

    push socket, "receive_map_data", %{listings: listings, bounds: message["bounds"]}
    {:noreply, socket}
  end

  def handle_in("request_listing_details", %{"url" => url}, socket) do
    listing = Search.fetch_by_url(url, get_user_id(socket))
    schools = schools_from_listing(listing)
    user = get_user(socket)

    view = View.render_to_string(
      Sre.PropertyView,
      "property.html",
      [listing: listing, schools: schools, user: user]
    )

    push socket, "receive_listing_details", %{
      title: ViewHelper.address(listing) <> " - SRE",
      url: url,
      view: view
    }

    {:noreply, socket}
  end

  def handle_in("request_listing_details", _, _socket) do raise BadInputError end

  defp schools_from_listing(nil), do: []
  defp schools_from_listing(listing), do: Query.fetch_schools_by_listing_id(listing.id)

  defp search_view_module(:table), do: TableList
  defp search_view_module(:homepage), do: HomepageList
  defp search_view_module(_), do: CardList

  defp search_view_template(:table), do: "table_list.html"
  defp search_view_template(:homepage), do: "homepage_list.html"
  defp search_view_template(_), do: "card_list.html"

  defp get_page_number(%{"page" => page}) do
    current_page = if is_integer page do
      page
    else
      case Integer.parse(page) do
        {page_number, _} -> page_number
        :error -> 1
      end
    end

    if current_page >= 1, do: current_page, else: 1
  end
  defp get_page_number(%{}) do 1 end

  def get_user_id(socket) do
    case Channels.get_user_id(socket) do
      {:ok, user_id} ->
        user_id

      {:error, _} ->
        nil
    end
  end

  def get_user(socket) do
    case get_user_id(socket) do
      nil ->
        nil

      id ->
        id
        |> User.get_user_by_id
        |> User.get_user_primary_phone
    end
  end
end
