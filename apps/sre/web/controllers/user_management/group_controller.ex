defmodule Sre.UserManagement.GroupController do

  use Sre.Web, :controller
  use Sre.Controller

  plug Sre.RequireLogin

  alias Group.ListingService, as: Api

  def index(conn, _params, user) do
    favorites = Api.fetch_by_user_id_and_name(user.id, "Favorites")
    conn
    |> render("index.html", [favorites: favorites])
  end
end
