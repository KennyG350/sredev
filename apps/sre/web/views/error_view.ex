defmodule Sre.ErrorView do
  use Sre.Web, :view

  def render("400.json", _assigns) do
    %{response: "Bad Request"}
  end

  def render("404.html", assigns) do
    render "not_found.html", assigns
  end

  # Error server errors without the page layout because
  # we don't know if the layout is triggering the error.
  def render("500.html", assigns) do
    render "server.html", assigns
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
