defmodule Sre.UI.Svg.Icon do
  use Sre.Web, :ui_component

  @defaults classes: [], icon: nil

  def render_template(opts \\ []) do
    new_opts = Keyword.merge(@defaults, opts)
    _render_template(new_opts[:icon], opts)
  end

  @doc """
  class_name takes `Map` of `type of class`
  """
  def class_name(classes, classname \\ "")
  def class_name(nil, classname), do: classname
  def class_name([], classname), do: classname
  def class_name(classes, classname) do
    classes
    |> Enum.intersperse(" ")
    |> Enum.reduce(classname <> " ", &(&2 <> &1))
    |> String.trim
  end

  defp _render_template(nil, _) do
    raise(
      ArgumentError,
      message: "`Sre.UI.Svg.Icon` needs to have an icon to render. Try passing an `icon` option to render_template function."
    )
  end

  defp _render_template(icon, opts) do
    render_opts = Keyword.merge(opts, classname: class_name(opts[:classes], "icon"), icon: icon)
    render "icon.html", render_opts
  end
end
