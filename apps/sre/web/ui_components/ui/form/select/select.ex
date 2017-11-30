defmodule Sre.UI.Form.Select do
  use Sre.Web, :ui_component

  @defaults [label: nil, id: nil, classname: nil, size: "md", disabled?: false, values: []]

  def render_template(opts \\ []) do
    render "select.html", Keyword.merge(@defaults, opts)
  end
end
