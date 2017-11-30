defmodule Sre.UI.Footer do
  use Sre.Web, :ui_component

  @defaults [classname: nil, current_user: nil]

  def copyright_year do
    Timex.format!(Timex.now, "{YYYY}")
  end

  def render_template(opts \\ []) do
    render "footer.html", Keyword.merge(@defaults, opts)
  end
end
