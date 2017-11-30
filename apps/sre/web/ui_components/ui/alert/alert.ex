defmodule Sre.UI.Alert do
  use Sre.Web, :ui_component

  @defaults [
    content: "Alert content",
    color_theme: "primary",
    outline: false,
    classname: "",
    can_close: true
  ]

  def render_template(opts \\ []) do
    render "alert.html", Keyword.merge(@defaults, opts)
  end
end
