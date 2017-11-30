defmodule Sre.UI.Form.Textarea do
  use Sre.Web, :ui_component

  @defaults [label: nil, id: nil, classname: nil, size: "md", disabled?: false]

  def render_template(opts \\ []) do
    render "textarea.html", Keyword.merge(@defaults, opts)
  end
end
