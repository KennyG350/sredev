defmodule Sre.UI.Property.Search.SearchFilters do
  use Sre.Web, :ui_component

  alias Sre.UI.Form.Select
  alias Sre.UI.Form.Input

  @defaults []

  @default_selection [%{:label => "Any", :value => nil}]

  @property_type_options [
    %{:label => "Single Family", :value => "Single Family"},
    %{:label => "Condo", :value => "Condo"},
    %{:label => "Townhome", :value => "Townhome"},
  ]

  @min_price_options [
    %{:label => "0", :value => 0},
    %{:label => "50K+", :value => 50_000},
    %{:label => "75K+", :value => 75_000},
    %{:label => "100K+", :value => 100_000},
    %{:label => "150K+", :value => 150_000},
    %{:label => "200K+", :value => 200_000},
    %{:label => "250K+", :value => 250_000},
    %{:label => "300K+", :value => 300_000},
    %{:label => "400K+", :value => 400_000},
    %{:label => "500K+", :value => 500_000},
    %{:label => "600K+", :value => 600_000},
    %{:label => "700K+", :value => 700_000},
    %{:label => "800K+", :value => 800_000},
    %{:label => "900K+", :value => 900_000},
    %{:label => "1M+", :value => 1_000_000},
    %{:label => "1.5M+", :value => 1_500_000},
    %{:label => "2M+", :value => 2_000_000},
    %{:label => "2.5M+", :value => 2_500_000},
    %{:label => "3M+", :value => 3_000_000},
    %{:label => "3.5M+", :value => 3_500_000},
    %{:label => "4M+", :value => 4_000_000},
    %{:label => "4.5M+", :value => 4_500_000},
  ]

  @max_price_options [
    %{:label => "150K", :value => 150_000},
    %{:label => "200K", :value => 200_000},
    %{:label => "250K", :value => 250_000},
    %{:label => "300K", :value => 300_000},
    %{:label => "400K", :value => 400_000},
    %{:label => "500K", :value => 500_000},
    %{:label => "600K", :value => 600_000},
    %{:label => "700K", :value => 700_000},
    %{:label => "800K", :value => 800_000},
    %{:label => "900K", :value => 900_000},
    %{:label => "1M", :value => 1_000_000},
    %{:label => "1.5M", :value => 1_500_000},
    %{:label => "2M", :value => 2_000_000},
    %{:label => "2.5M", :value => 2_500_000},
    %{:label => "3M", :value => 3_000_000},
    %{:label => "3.5M", :value => 3_500_000},
    %{:label => "4M", :value => 4_000_000},
    %{:label => "4.5M", :value => 4_500_000},
    %{:label => "5M", :value => 5_000_000},
    %{:label => "5.5M", :value => 5_500_000},
  ]

  @bathroom_options [
    %{:label => "1+", :value => 1},
    %{:label => "2+", :value => 2},
    %{:label => "3+", :value => 3},
    %{:label => "4+", :value => 4},
  ]

  @bedroom_options [
    %{:label => "1+", :value => 1},
    %{:label => "2+", :value => 2},
    %{:label => "3+", :value => 3},
    %{:label => "4+", :value => 4},
    %{:label => "5+", :value => 5},
    %{:label => "6+", :value => 6},
    %{:label => "7+", :value => 7},
    %{:label => "8+", :value => 8},
  ]

  def render_template(opts \\ []) do
    render "search_filters.html", Keyword.merge(@defaults, opts)
  end

  def render_location(filters) do
    Input.render_template(
      id: "location",
      label: "Location",
      type: "text",
      value: filters[:location],
      placeholder: "Enter a location...",
      classname: "search-filter__main__input search-filters__location"
    )
  end

  def render_option(:type, filters) do
    Select.render_template(
      id: "type",
      label: "Property Type",
      options: get_options(@property_type_options, filters[:type]),
      classname: "search-filter__main__input search-filters__type"
    )
  end

  def render_option(:min_price, filters) do
    Select.render_template(
      id: "price_min",
      label: "Price Min",
      options: get_options(@min_price_options, filters[:price_min]),
      classname: "input-range__min"
    )
  end

  def render_option(:max_price, filters) do
    Select.render_template(
      id: "price_max",
      label: "Price Max",
      options: get_options(@max_price_options, filters[:price_max]),
      classname: "input-range__max"
    )
  end

  def render_option(:bathroom, filters) do
    Select.render_template(
      id: "bathrooms",
      label: "Bathrooms",
      options: get_options(@bathroom_options, filters[:bathrooms]),
      classname: "input-range__max"
    )
  end

  def render_option(:bedroom, filters) do
    Select.render_template(
      id: "bedrooms",
      label: "Bedrooms",
      options: get_options(@bedroom_options, filters[:bedrooms]),
      classname: "input-range__min"
    )
  end

  defp get_options(options, selected_value) do

    # Include default "Any" option
    options = @default_selection ++ options

    options
    |> Enum.map(&select_option(&1, selected_value))
  end

  defp select_option(option, selected_value) do
    Map.put(option, :selected, option.value === selected_value)
  end
end
