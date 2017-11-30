defmodule Sre.UI.Property.PropertyAside do
  use Sre.Web, :ui_component

  alias Sre.Listing.ViewHelper

  @defaults []

  def render_template(opts \\ []) do
    render "property_aside.html", Keyword.merge(@defaults, opts)
  end

  def get_list_price(listing) do
    ViewHelper.format_number(listing.price)
  end

end
