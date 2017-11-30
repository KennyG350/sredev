defmodule Sre.UI.Property.Search.SearchNav do
  use Sre.Web, :ui_component

  @defaults [link_to: nil]

  @sort_options [
    %{:label => "Recently Added", :value => "recent"},
    %{:label => "Highest Price", :value => "highest_price"},
    %{:label => "Lowest Price", :value => "lowest_price"}
  ]

  def render_template(opts \\ []) do
    render "search_nav.html", Keyword.merge(@defaults, opts)
  end

  def get_sort_options selected_order do
    @sort_options
    |> Enum.map(&select_option(&1, selected_order))
  end

  def get_view_selector_link(url_params) do
    IO.warn url_params
  end

  def get_url_params(:table, url_params) do get_url_params(nil, Map.put(url_params, "view", "table")) end
  def get_url_params(:card, url_params) do get_url_params(nil, Map.delete(url_params, "view")) end
  def get_url_params(_view, url_params) do
    URI.encode_query(url_params)
  end

  defp select_option(option, selected_value) do
    Map.put(option, :selected, option.value === selected_value)
  end
end
