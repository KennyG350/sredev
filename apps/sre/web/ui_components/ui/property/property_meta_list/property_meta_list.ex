defmodule Sre.UI.Property.PropertyMetaList do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "property_meta_list.html", Keyword.merge(@defaults, opts)
  end
end
