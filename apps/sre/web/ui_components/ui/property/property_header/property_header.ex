defmodule Sre.UI.Property.PropertyHeader do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "property_header.html", Keyword.merge(@defaults, opts)
  end
end
