defmodule Sre.UI.Property.PropertyAccordion.OtherInfo do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "other_info.html", Keyword.merge(@defaults, opts)
  end
end
