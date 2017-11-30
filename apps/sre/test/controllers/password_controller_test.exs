defmodule Sre.PasswordControllerTest do

  use Sre.ConnCase

  alias User.PasswordToken
  alias Schema.{
    Repo,
    Resource.User
  }

  describe "Forgot Password" do
    setup %{conn: conn} do
      conn = %{conn | host: "localhost"}
      {:ok, conn: conn}
    end

    test ".forgot_password form", %{conn: conn} do
      resp = get(conn, password_path(conn, :reset_password, %{action: "forgot_password"}))
      assert html_response(resp, 200)
      assert resp.assigns.action == :forgot_password
    end

    test ".change_password form", %{conn: conn} do
      resp = get(conn, password_path(conn, :reset_password, %{action: "change_password"}))
      assert html_response(resp, 200)
      assert resp.assigns.action == :change_password
    end

  end

  describe "Change Password from Email Link" do
    setup [:set_user]

    test ".request-reset", %{conn: conn, user: user} do
      resp = post(conn, password_path(conn, :request_reset), %{
        "email_address" => user.email
        })
      assert_received {:delivered_email, _}
    end

    test ".edit-password", %{conn: conn, user: user} do
      data = %{
        token: user.forgot_password_token,
        email: user.email,
        action: "forgot_password"
      }
      resp = get(conn, password_path(conn, :edit), data)
      assert html_response(resp, 200)
    end

    test ".change-password", %{conn: conn, user: user} do
      data = %{token: user.forgot_password_token, email: user.email}
      resp = put(conn, user_management_password_path(conn, :update, user), data)
      assert html_response(resp, 200)
    end

  end

  def set_user(%{conn: conn}) do
    conn = %{conn | host: "localhost"}
    user =  Repo.insert!(struct(User, user_details))
    user =  PasswordToken.set_reset_password_token(user)
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

end
