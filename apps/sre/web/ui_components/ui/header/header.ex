defmodule Sre.UI.Header do
  use Sre.Web, :ui_component

  @defaults [classname: nil]

  def render_template(opts \\ []) do
    render "header.html", Keyword.merge(@defaults, opts)
  end
end
