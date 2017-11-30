defmodule Sre.UI.Property.PropertyAccordion.CommunityInfo do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "community_info.html", Keyword.merge(@defaults, opts)
  end
end
