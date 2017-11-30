defmodule Sre.UI.Property.List.TableList do
  use Sre.Web, :ui_component

  @defaults []

  def render_template(opts \\ []) do
    render "table_list.html", Keyword.merge(@defaults, opts)
  end
end
