defmodule Sre.UI.Header.Search.LocationSearch do
  use Sre.Web, :ui_component

  @defaults [classname: nil, back_button?: false]

  def render_template(opts \\ []) do
    render "location_search.html", Keyword.merge(@defaults, opts)
  end
end
