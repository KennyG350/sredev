defmodule Sre.UI.Header.Search.SearchSummary do
  use Sre.Web, :ui_component

  @defaults [classname: nil]

  def render_template(opts \\ []) do
    render "search_summary.html", Keyword.merge(@defaults, opts)
  end

  def get_location(filters) do
    filters[:location] || "Search Location..."
  end
end
