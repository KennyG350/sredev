defmodule Sre.UI.Property.PropertyAccordion.InteriorFeatures do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "interior_features.html", Keyword.merge(@defaults, opts)
  end
end
