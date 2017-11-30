defmodule Sre.UI.Property.PropertyAccordion.AdditionalInfo do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "additional_info.html", Keyword.merge(@defaults, opts)
  end

  def days_ago(listing) do
    if listing.last_modified == nil or listing.last_modified == "" do
      "-"
    else
      Timex.diff(Timex.now, listing.last_modified, :days)
    end
  end

  def last_updated(listing) do
    Timex.format!(listing.last_modified, "{h12}:{s}{am} {M}/{D}/{YYYY}")
  end
end
