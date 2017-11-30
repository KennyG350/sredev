defmodule Sre.UI.Header.Nav.MainNav do
  use Sre.Web, :ui_component

  @defaults [classname: nil]

  def render_template(opts \\ []) do
    render "main_nav.html", Keyword.merge(@defaults, opts)
  end

  def full_name(%{first_name: nil, last_name: nil, email: email}) do
    "#{email}"
  end

  def full_name(%{first_name: nil, email: email}) do
    "#{email}"
  end

  def full_name(%{last_name: nil, email: email}) do
    "#{email}"
  end

  def full_name(user) do
    user.first_name <> " " <> user.last_name
  end

end
