defmodule Sre.UI.Property.PropertyAccordion.TaxInfo do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "tax_info.html", Keyword.merge(@defaults, opts)
  end
end
