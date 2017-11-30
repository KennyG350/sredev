defmodule Sre.UI.Property.PropertyAccordion.ExteriorFeatures do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "exterior_features.html", Keyword.merge(@defaults, opts)
  end
end
