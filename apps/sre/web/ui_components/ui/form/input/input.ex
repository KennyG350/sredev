defmodule Sre.UI.Form.Input do
  use Sre.Web, :ui_component

  @defaults [
    type: "text",
    label: nil,
    id: nil,
    classname: nil,
    size: "md",
    disabled?: false,
    placeholder: nil,
    value: nil
  ]

  def render_template(opts \\ []) do
    render "input.html", Keyword.merge(@defaults, opts)
  end

end
