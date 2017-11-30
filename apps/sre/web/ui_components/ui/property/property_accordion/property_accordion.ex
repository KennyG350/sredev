defmodule Sre.UI.Property.PropertyAccordion do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "property_accordion.html", Keyword.merge(@defaults, opts)
  end

  def legal_text listing do
    legal_disclaimer = listing.feed.feed_connection.legal_disclaimer || ""

    last_updated_date = if listing.last_modified do
      Timex.format!(listing.last_modified, "{M}/{D}/{YYYY}")
    else
      "-"
    end

    # Add listing date
    legal_disclaimer
    |> String.replace("{listing_date}", last_updated_date)
  end

end
