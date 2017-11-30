defmodule Sre.UI.Property.PropertyRemarks do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "property_remarks.html", Keyword.merge(@defaults, opts)
  end
end
