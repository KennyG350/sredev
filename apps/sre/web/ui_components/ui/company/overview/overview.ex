defmodule Sre.UI.Company.Overview do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "overview.html", Keyword.merge(@defaults, opts)
  end
end
