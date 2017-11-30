defmodule Sre.Listing.ViewHelper do
  @moduledoc """
  Helper functions for formatting common listing data.
  """

  import Phoenix.HTML.Tag, only: [content_tag: 2, content_tag: 3]
  import Phoenix.HTML, only: [raw: 1, safe_to_string: 1]

  @photo_cdn Application.get_env(:sre, :photo_cdn)
  @placeholder_img_map %{position: nil, path: @photo_cdn <> "website-photos/property-hero--placeholder.jpg", description: "placeholder"}
  @rebate_restricted_state ["AL", "OK", "MO"]
  @no_discount_states ["KS", "TN"]

  alias Number.Currency
  alias Number.Delimit
  alias Number.Phone

  def listing_detail(_, nil, :no_format), do: nil
  def listing_detail(_, "",  :no_format),  do: nil
  def listing_detail(title, value, :no_format) do
    build_list_tag(title, "#{value}")
  end

  def listing_detail(_, nil, :money), do: nil
  def listing_detail(_, "",  :money),  do: nil
  def listing_detail(title, value, :money) do
    value = format_currency(value)
    build_list_tag(title, value)
  end

  def listing_detail(_, nil), do: nil
  def listing_detail(_, ""), do: nil

  def listing_detail(title, val) when is_boolean(val) do
    val =
      case val do
        true -> "Yes"
        _ -> "No"
      end
    build_list_tag(title, val)
  end

  def listing_detail(title, val) when val in ["true", "false"] do
    val =
      case val do
        "true" -> "Yes"
        _ -> "No"
      end
    build_list_tag(title, val)
  end

  def listing_detail(title, detail) do
    val = do_listing_detail(detail)
    build_list_tag(title, val)
  end

  defp build_list_tag(title, value) do
    :li
    |> content_tag do
      do_build_display_safe(title, value)
    end
    |> raw
  end

  defp do_build_display_safe(title, value) do
    title =
    title
    |> do_listing_detail_title
    |> safe_to_string
    raw (title <> value)
  end

  defp do_listing_detail_title(title) do
    content_tag(:strong, class: "strong") do
      title
    end
  end

  defp do_listing_detail(value)
  when is_float(value) do
    format_number(value)
  end

  defp do_listing_detail(value)
  when is_integer(value) do
    format_number(value)
  end

  defp do_listing_detail(value)
  when is_binary(value) do
    ~r{,}
    |> Regex.split(value)
    |> Enum.count
    |> case do
       1 -> value
       val when val > 1 -> Enum.join(String.split(value, ","), ", ")
    end
  end

  defp do_listing_detail(%Decimal{} = value) do
    format_number(value)
  end

  defp do_listing_detail(val) do
    val
  end

  def days_on_market(listing) do
    if listing.original_entry_timestamp === nil do
      "-"
    else
      Timex.diff(Timex.now, listing.original_entry_timestamp, :days)
    end
  end

  def address(listing) do
    [street_address(listing), city_state_zip(listing)]
    |> Enum.intersperse(" ")
    |> List.foldl("", &(&2 <> &1))
  end

  def street_address(listing) do
    unit_number = if is_nil(listing.unit_number) or listing.unit_number == "" do
      nil
    else
      "#" <> listing.unit_number
    end

    # Format street address, ignoring parts we don't have.
    street_address = [
      listing.street_number,
      listing.street_dir_prefix,
      listing.street_name,
      listing.street_suffix,
      listing.street_dir_suffix,
      unit_number,
    ]
      |> Enum.reject(fn(v) -> is_nil(v) || v === "" end)
      |> Enum.join(" ")

    street_address
  end

  def city_state_zip(listing) do
    "#{listing.city}, #{listing.state} #{listing.zip_code}"
  end

  def price_per_sqft(listing) do
    if listing.price === nil or listing.living_area === nil do
      "-"
    else
      price_per_sqft(get_int(listing.price), get_int(listing.living_area))
    end
  end
  def price_per_sqft(price, living_area) when living_area > 0, do: price |> div(living_area) |> format_currency
  def price_per_sqft(_price, living_area) when living_area <= 0, do: "-"

  def format_lot_size(lot_size) do
    if lot_size == nil or lot_size == "" or lot_size == 0 do
      "-"
    else
      format_number(lot_size) <> " SQFT"
    end
  end

  def format_comma_list(string) do
    if string == nil or string == "" do
      "-"
    else
      Enum.join(String.split(string, ","), ", ")
    end
  end

  def concat_monthly(string) do
    string <> "/mo"
  end

  @doc """
  date_listed

  Returns a formatted string of the listed date or placeholder text when there isn't a valid
  list date.
  """
  def date_listed(listing) do
    if listing.original_entry_timestamp == nil or listing.original_entry_timestamp == "" do
      "-"
    else
      Timex.format!(listing.original_entry_timestamp, "{M}/{D}/{YYYY}")
    end
  end

  def get_list_price(listing) do
    listing.price
    |> number_to_string
    |> Delimit.number_to_delimited(precision: 0)
  end

  def get_rebate_amount(listing) do
    listing
    |> rebate_amount
    |> format_number
  end

  def get_price_after_rebate(listing) do
    if listing.price === nil do
      "-"
    else
      listing.price
      |> Decimal.sub(rebate_amount(listing))
      |> format_number
    end
  end

  @doc """
  number

  Takes an `value` string and returns a comma delimited number or placeholder text..
  """
  def format_number(nil) do "-" end
  def format_number("") do "-" end
  def format_number(value) do
    value
      |> number_to_string
      |> Delimit.number_to_delimited(precision: 0)
  end

  @doc """
  currency

  Takes an `value` string and returns USD formatted currency string or placeholder text..
  """
  def format_currency(nil) do "-" end
  def format_currency("") do "-" end
  def format_currency(value) do
    value
      |> number_to_string
      |> Currency.number_to_currency(precision: 0)
  end

  def number_to_string(nil) do "" end
  def number_to_string(value) when is_float(value) do
    Float.to_string value
  end

  def number_to_string(value) when is_integer(value) do
    Integer.to_string value
  end

  def number_to_string(value) when is_binary(value) do
    value
  end

  def number_to_string(%Decimal{sign: _, coef: _, exp: _} = value) do
    Decimal.to_string value
  end

  @doc """
  has_rebate/1

  Checks to see if a listing has a rebate amount.

  """
  def has_rebate(listing) do
    if Enum.member?(@no_discount_states, listing.state) do
      false
    else
      rebate_amount = get_in(listing, [Access.key(:feed, %{}), Access.key(:feed_connection, %{}), Access.key(:rebate_amount, nil)])

      cond do
        rebate_amount === nil -> false
        rebate_amount === Decimal.new(0) -> false
        true -> true
      end
    end
  end

  @doc """
  has_rebate/2

  Never show the rebate amount on cards for Oklahoma, Missouri and Alabama.
  """
  def has_rebate(listing, :card_view) do
    if Enum.member?(@no_discount_states, listing.state) do
      false
    else
      has_rebate(listing)
    end
  end

  @doc """
  get_rebate_text/1

  We can't use the word rebate in Oklahoma, Missouri or Alabama so use Savings instead.
  """
  def get_rebate_text(listing) do
    if Enum.member?(@rebate_restricted_state, listing.state) do
      "Savings"
    else
      "Rebate"
    end
  end

  @doc """
  get_rebate_text/1

  We can't use the word rebate in Oklahoma, Missouri or Alabama so use Savings instead.
  """
  def get_rebates_text(listing) do
    if Enum.member?(@rebate_restricted_state, listing.state) do
      "savings"
    else
      "rebates"
    end
  end

  @doc """
  to_acres/1

  Takes `sqft` and returns the converted square footage to acre size.

  ## Examples

      iex> Sre.Listing.ViewHelper.to_acres nil
      "-"
      iex> Sre.Listing.ViewHelper.to_acres 43560
      1.00

  """
  def to_acres(nil), do: "-"
  def to_acres(sqft) do
    sqft_string = number_to_string sqft
    case Float.parse(sqft_string) do
      {num, _} ->
        acres = num / 43_560
        acres
        |> Float.round(2)

      :error ->
        "-"
    end
  end

  @doc """
  format_boolean/1

  Takes boolean value and returns Yes or No.

  ## Examples

      iex> Sre.Listing.ViewHelper.format_boolean nil
      "-"
      iex> Sre.Listing.ViewHelper.format_boolean true
      "Yes"

  """

  def format_boolean(val) when val in [true, "true"], do: "Yes"
  def format_boolean(val) when val in [false, "false"], do: "No"
  def format_boolean(_), do: "-"

  @doc """
  render_ACR/1

  Handles append ACR to the end of the Acre string

  ## Examples

    iex> Sre.Listing.ViewHelper.render_ACR "-"
    "-"
    iex> Sre.Listing.ViewHelper.render_ACR "123.12"
    "123.12 ACR"
    iex> Sre.Listing.ViewHelper.render_ACR 123.12
    "123.12 ACR"

  """
  def render_ACR("-"), do: "-"
  def render_ACR(sqft) when is_binary(sqft), do: sqft <> " ACR"
  def render_ACR(sqft) when is_float(sqft), do: Float.to_string(sqft) <> " ACR"

  def show_co_branding?(listing) do
    get_in(listing, [Access.key(:feed, %{}), Access.key(:feed_connection, %{}), Access.key(:co_branding, nil)]) === true
  end

  def get_mls_logo(listing) do
    if listing.feed.feed_connection.logo_path != nil do
      Application.get_env(:sre, :photo_cdn) <> listing.feed.feed_connection.logo_path
    else
      ""
    end
  end

  defp rebate_amount(listing) do
    rebate_amount = get_in(listing, [Access.key(:feed, %{}), Access.key(:feed_connection, %{}), Access.key!(:rebate_amount)])

    if rebate_amount === nil or listing.price === nil do
      Decimal.new(0)
    else
      rebate_amount
      |> Decimal.mult(listing.price)
    end
  end

  defp get_int(value) do
     case value |> number_to_string |> Integer.parse do
        {int, _} -> int
        :error -> 0
     end
  end

  @doc """
  get_search_view/1

  Returns an atom representing a search view (:table or :card depending on whether the argument is "table")
  """
  def get_search_view("table") do :table end
  def get_search_view("homepage") do :homepage end
  def get_search_view(_) do :card end

  def prepend_cdn_to_path(path, cdn \\ @photo_cdn), do: cdn <> path

  def format_photo_url(%{path: path} = photo) when is_map photo do
    photo
    |> Map.put(:path, prepend_cdn_to_path(path))
  end

  def format_photo_url(photos) when is_list photos do
    if Enum.empty? photos do
      [@placeholder_img_map]
    else
      photos |> Enum.map(&format_photo_url/1)
    end
  end

  def get_phone_number(%Sre.UserLocation{state: state}) do
    phone_numbers = Application.get_env(:sre, :office_phone_numbers)

    case state do
      "AZ" -> phone_numbers[:az]
      "CA" -> phone_numbers[:ca]
      "HI" -> phone_numbers[:hi]
      "WI" -> phone_numbers[:wi]
      _ -> phone_numbers[:default]
    end
  end

  def get_formatted_phone_number(user_location) do
    user_location
    |> get_phone_number
    |> Phone.number_to_phone(area_code: true)
  end

  @doc """
  gets all the unique legal disclaimer from a listings feed connections
  """
  def get_uniq_discliamers([]), do: []
  def get_uniq_discliamers(listings) do
    listings
    |> Enum.map(fn l -> l.feed.feed_connection end)
    |> Enum.uniq_by(fn %{id: id} -> id end)
    |> Enum.map(fn fc -> fc.legal_disclaimer end)
    |> Enum.filter(& not(is_nil(&1)))
  end
end
