defmodule ListingSearch.Filters do

  def valid_filters(filters) do
    %{
      :bounds => to_string_or_nil(filters["bounds"]),
      :location => to_string_or_nil(filters["location"]),
      :type => to_string_or_nil(filters["type"]),
      :bedrooms => to_integer_or_nil(filters["bedrooms"]),
      :bathrooms => to_integer_or_nil(filters["bathrooms"]),
      :price_min => to_integer_or_nil(filters["price_min"]),
      :price_max => to_integer_or_nil(filters["price_max"]),
      :home_size_min => to_integer_or_nil(filters["home_size_min"]),
      :lot_size_min => to_integer_or_nil(filters["lot_size_min"]),
      :year_built_min => to_integer_or_nil(filters["year_built_min"]),
      :exclude_condo => to_boolean_or_nil(filters["exclude_condo"]),
      :exclude_house => to_boolean_or_nil(filters["exclude_house"]),
      :exclude_townhouse => to_boolean_or_nil(filters["exclude_townhouse"]),
    }
  end

  def to_string_or_nil nil do nil end
  def to_string_or_nil "" do nil end
  def to_string_or_nil value do
    # Handle url encoded data too
    URI.decode(value)
  end

  def to_integer_or_nil nil do nil end
  def to_integer_or_nil value do
    case Integer.parse(value) do
      {value, _} -> value
      :error -> nil
    end
  end

  def to_boolean_or_nil nil do nil end
  def to_boolean_or_nil "" do nil end
  def to_boolean_or_nil _value do
    true
  end
end
