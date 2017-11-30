defmodule Sre.PropertyController do
  use Sre.Web, :controller

  alias Sre.Listing.ViewHelper
  alias Sre.Router
  alias ListingSearch.{
    Search,
    Filters,
    NoResultsError,
    BadInputError
  }

  alias User.Search, as: UserSearch
  alias GreatSchools.Query

  def index(conn, params) do
    %{
      listings: listings,
      page: page,
      filters: filters,
      order_by: order_by,
      view: view,
      params: params
    # Note: DO NOT preload :groups or else favorites from OTHER PEOPLE will show
    } = build_list_search_response(params, [:photos, feed: :feed_connection], conn.assigns.current_user)

    saved_search =
      params
      |> UserSearch.hash_search_params
      |> UserSearch.get_user_search_hash(conn.assigns.current_user)

    render(conn, "search.html", [
      filters: filters,
      listings: listings,
      order_by: order_by,
      page_title: "Search Results", # @todo: Show search location in page title
      page: page,
      total_results: Search.count(filters: filters),
      url_params: params,
      view: view,
      saved_search: saved_search,
      show_location_search: false
    ])
  end

  def details(conn, %{"url" => nil}) do
    raise BadInputError, input: nil, conn: conn, router: Router
  end

  def details(conn, %{"url" => url}) do
    user = conn.assigns[:current_user]

    url
    |> Search.fetch_by_url(user_id(user))
    |> render_details_page(conn)
  end

  defp render_details_page(nil, %{params: %{"url" => url}} = conn) do
    raise NoResultsError, url: url, conn: conn, router: Router
  end

  defp render_details_page(listing, conn) do
    schools = Query.fetch_schools_by_listing_id(listing.id)
    conn = assign(conn, :schools, schools)

    render(
      conn,
      "property.html",
      listing: listing,
      page_title: "View #{listing.bedrooms} Bed, #{listing.baths} Bath, #{listing.type} home for sale in "
                  <> "#{listing.city}, #{listing.state} - ##{listing.mls_listing_id}",
      page_description: "View this #{listing.bedrooms} Bedroom, #{listing.baths} Bathroom #{listing.type} home for sale "
                      <> "located in #{listing.city}, #{listing.state} #{listing.zip_code}. Contact an SRE Agent today and "
                      <> "schedule a tour for this MLS listing ##{listing.mls_listing_id}",
      user: conn.assigns[:current_user] |> User.get_user_primary_phone
    )
  end

  defp get_page_number(%{"page" => page}) do
    current_page = case Integer.parse(page) do
      {page_number, _} -> page_number
      :error -> 1
    end

    if current_page >= 1, do: current_page, else: 1
  end
  defp get_page_number(%{}) do 1 end

  defp build_list_search_response(params, preloads, user) do
    page = get_page_number(params)
    order_by = params["sort"]
    filters = Filters.valid_filters(params)
    view = ViewHelper.get_search_view(params["view"])
    per_page = Application.get_env(:sre, :listings_per_page_per_view)[view]

    listings = Search.fetch(
      preload: preloads,
      page: page,
      per_page: per_page,
      filters: filters,
      order_by: order_by,
      user_id: user_id(user)
    )

    %{listings: listings,
      page: page,
      filters: filters,
      order_by: order_by,
      view: view,
      params: params,
      count: Search.count filters: filters
     }
  end

  defp user_id(nil), do: nil
  defp user_id(user), do: user.id
end
