defmodule Sre.UserControllerTest do
  use Sre.ConnCase

  alias Schema.{
    Repo,
    Resource.User
  }

  describe "Access" do

    setup %{conn: conn} do
      conn =
        %{conn | host: "localhost"}
      user =  Repo.insert!(struct(User, user_details))
      conn =
        conn
        |> assign(:current_user, user)
        |> assign(:user_id, user.id)

      {:ok, conn: conn, user: user}
    end

    test "should only happen if user is logged in", %{conn: conn, user: user} do
      response = get(conn, user_management_user_path(conn, :edit, user))
      assert html_response(response, 200)
    end

  end
end
