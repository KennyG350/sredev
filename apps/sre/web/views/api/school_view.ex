defmodule Sre.SchoolView do
  use Sre.Web, :view

  def render("schools.json", %{schools: schools}) do
    schools
  end
end
