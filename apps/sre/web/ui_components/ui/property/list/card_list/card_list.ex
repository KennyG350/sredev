defmodule Sre.UI.Property.List.CardList do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "card_list.html", Keyword.merge(@defaults, opts)
  end

end
