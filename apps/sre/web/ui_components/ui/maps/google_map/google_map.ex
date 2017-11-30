defmodule Sre.UI.Maps.GoogleMap do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "google_map.html", Keyword.merge(@defaults, opts)
  end
end
