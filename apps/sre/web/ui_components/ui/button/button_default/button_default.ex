defmodule Sre.UI.Button.ButtonDefault do
  use Sre.Web, :ui_component

  @defaults [
    type: "submit",
    value: "Default Button",
    classname: "button__primary",
    disabled?: false
  ]

  def render_template(opts \\ []) do
    render "button_default.html", Keyword.merge(@defaults, opts)
  end
end
