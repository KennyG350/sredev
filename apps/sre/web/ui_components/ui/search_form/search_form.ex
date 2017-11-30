defmodule Sre.UI.SearchForm do
  use Sre.Web, :ui_component

  @defaults [classname: ""]

  def render_template(opts \\ []) do
    render "search_form.html", Keyword.merge(@defaults, opts)
  end
end
