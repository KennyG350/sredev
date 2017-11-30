defmodule Sre.UI.Property.PropertyRebateFormula do
  use Sre.Web, :ui_component

  @defaults [classname: ""]

  def render_template(opts \\ []) do
    render "property_rebate_formula.html", Keyword.merge(@defaults, opts)
  end
end
