defmodule Sre.PageController do
  use Sre.Web, :controller

  alias Testimonials.Cache, as: TestimonialsCache
  alias Feeds.Cache, as: FeedsCache
  alias ListingSearch.Search
  alias Phoenix.View
  alias Sre.Mailer
  alias Sre.Emails

  # +/- 15% of the buy slider starting price: $500k
  @buy_page_min_price 425_000.0
  @buy_page_max_price 575_000.0

  def index(conn, _params) do
    location = conn.assigns[:user_location]

    render(
      conn,
      "index.html",
      feeds_json: FeedsCache.get()[:feeds_json],
      page_title: "Search Houses for Sale, Brand New MLS Listings & More",
      page_description: "Buying or selling a house has never been easier! Visit SRE.com and browse our selection of MLS "
                        <> "listings to find your perfect home. Selling a house? We can help there too! Click to find out more.",
      user_location: location
    )
  end

  def testimonials(conn, _params) do
    render(
      conn,
      "testimonials.html",
      page_title: "SRE Customer Reviews & Testimonials",
      page_description: "With SRE, your satisfaction always comes first. Check out our customer reviews and hear how we've "
                      <> "helped them all into their new happy home!",
      testimonials: TestimonialsCache.get
    )
  end

  def savings(conn, _params) do
    conn
      |> put_status(301)
      |> redirect(to: "/testimonials")
  end

  def buying(conn, _params) do
    location = conn.assigns[:user_location]

    render(
      conn,
      "buying.html",
      user: conn.assigns[:current_user] |> User.get_user_primary_phone,
      user_location: location,
      nearby_listings: Search.fetch_by_city_state_and_price(
        location.city,
        location.state,
        @buy_page_min_price,
        @buy_page_max_price
      ),
      nearby_listings_count: Search.city_state_and_price_count(
        location.city,
        location.state,
        @buy_page_min_price,
        @buy_page_max_price
      ),
      page_title: "Buying a Home - How To Buy & Save with Your Home Purchase",
      page_description: "Buying a home can be a challenging, SRE's realtors can help you streamline and navigate the home "
                        <> "buying process, as well as best utilize our real estate rebate program. Contact to find out more!",
      min_price: @buy_page_min_price,
      max_price: @buy_page_max_price
    )
  end

  def selling(conn, _params) do
    render(
      conn,
      "selling.html",
      page_title: "Selling Your Home with SRE - Find Your Home Value & Sell Fast",
      page_description: "The first step to selling your home is knowing what your home is worth! The experienced team within SRE can "
      <> "help find your home value, get it listed, and get it sold!",
      user: conn.assigns[:current_user] |> User.get_user_primary_phone
    )
  end

  def solution(conn, _params) do
    render conn, "solution.html"
  end

  def platform(conn, _params) do
    render conn, "platform.html"
  end

  def mortgage(conn, _params) do
    render conn, "mortgage.html"
  end

  def home_mortgage_rate_calculator(conn, _params) do
    render(
      conn,
      "home-mortgage-rate-calculator.html",
      page_title: "The Smart Mortgage Robot | Home Mortgage Rate Calculator",
      page_description: "Estimating your mortgage payment has never been easier! SRE's new Smart Mortgage Robot will help you calculate "
      <> "home affordability for your home-buying prospects. Click to see how!",
    )
  end

    def fintech(conn, _params) do
    render conn, "fintech.html"
  end

  def partners(conn, _params) do
    render conn, "partners.html"
  end

  def terms(conn, _params) do
    render conn, "terms.html"
  end

  def privacy(conn, _params) do
    render conn, "privacy.html"
  end

  def contact(conn, _params) do
    render conn, "contact.html", user: conn.assigns[:current_user] |> User.get_user_primary_phone
  end

  def agency(conn, _params) do
    render conn, "agency.html"
  end

  def careers(conn, _params) do
    render conn, "careers.html"
  end
   def rewards(conn, params) do
    render conn, "rewards.html", contact_sent: params["sent"]
  end

  def send_rewards_message(conn, params) do
   params |> Emails.rewards_email |> Mailer.deliver_now

    conn
    |> redirect(to: "/rewards?sent=true")
  end

  def sitemap(conn, _params) do
    case HTTPoison.get("https://storage.googleapis.com/sre-com-assets/sitemap.xml") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        conn
        |> put_resp_content_type("text/xml")
        |> send_resp(200, body)
      _ ->
        conn
        |> send_resp(404, "Sitemap not found.")
    end
  end

  def error_500(conn, _params) do
    view = View.render_to_string(Sre.ErrorView, "500.html", %{:conn => conn})

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(500, view)
  end

  def error_404(conn, _params) do
    view = View.render_to_string(Sre.ErrorView, "not_found.html", %{:conn => conn})

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(404, view)
  end
end
