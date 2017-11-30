defmodule Sre.UI.Card.LocationCard do
  use Sre.Web, :ui_component

  @defaults location: "Honolulu, HI", image_path: "/images/location.jpg"

  def render_template(opts \\ []) do
    render "location_card.html", Keyword.merge(@defaults, opts)
  end
end
