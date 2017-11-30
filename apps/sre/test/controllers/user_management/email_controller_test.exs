defmodule Sre.UserManagement.EmailControllerTest do
  use Sre.ConnCase

  alias Schema.{Repo, Resource.User}

  describe "Ensures that email reset functionality works" do

    setup %{conn: conn} do
      conn =
        %{conn | host: "localhost"}
      user =  Repo.insert!(struct(User, user_details))
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    end

    test ".edit view", %{conn: conn, user: user} do
      resp = get(conn, user_management_email_path(conn, :edit, user.id))
      assert html_response(resp, 200)
    end

    test ".update", %{conn: conn, user: user} do
      assert is_nil user.verify_email_token

      data = %{"email" => "new-email@sre.com"}
      resp = put(conn, user_management_email_path(conn, :update, user.id), data)
      assert_received {:delivered_email, _}
      assert html_response(resp, 200)

      user = Repo.get_by(User, email: user.email)
      assert is_binary(user.verify_email_token)

      refute is_nil(user.verify_email_expiration)
    end
  end
end
