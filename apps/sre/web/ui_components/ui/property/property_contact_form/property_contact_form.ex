defmodule Sre.UI.Property.PropertyContactForm do
  use Sre.Web, :ui_component

  @defaults listing: %{}

  def render_template(opts \\ []) do
    render "property_contact_form.html", Keyword.merge(@defaults, opts)
  end
end
