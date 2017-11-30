defmodule Sre.EmailView do
  use Sre.Web, :view

  def render("email.json", %{status: status}) do
    %{status: status}
  end
end
