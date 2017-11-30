defmodule Sre.UI.Property.List.HomepageList do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "homepage_list.html", Keyword.merge(@defaults, opts)
  end
end
