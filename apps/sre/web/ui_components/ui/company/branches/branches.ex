defmodule Sre.UI.Company.Branches do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "branches.html", Keyword.merge(@defaults, opts)
  end
end
