defmodule Sre.UI.Property.PropertyDetailsFavoriteButton do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "property_details_favorite_button.html", Keyword.merge(@defaults, opts)
  end
end
