defmodule Sre.UI.Property.List.TableRow do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "table_row.html", Keyword.merge(@defaults, opts)
  end
end
