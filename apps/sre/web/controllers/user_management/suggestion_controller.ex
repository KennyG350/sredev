defmodule Sre.UserManagement.SuggestionController do
  use Sre.Web, :controller
  use Sre.Controller

  plug Sre.RequireLogin

  alias Sre.UserSuggestion

  def index(conn, _, user) do
    suggestions = UserSuggestion.fetch(user.id)
    conn
    |> assign(:suggestions, suggestions)
    |> render(:index)
  end

end
