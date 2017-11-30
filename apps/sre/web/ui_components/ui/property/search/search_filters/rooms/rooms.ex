defmodule Sre.UI.Property.Search.SearchFilters.Rooms do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "rooms.html", Keyword.merge(@defaults, opts)
  end
end
