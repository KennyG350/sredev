defmodule Sre.UserManagement.PageController do
  use Sre.Web, :controller

  plug Sre.RequireLogin

  def index(conn, _params) do
    redirect(conn, to: user_management_user_path(conn, :edit))
  end
end
