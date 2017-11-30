defmodule Sre.UI.Property.PropertyDetailsMap do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "property_details_map.html", Keyword.merge(@defaults, opts)
  end
end
