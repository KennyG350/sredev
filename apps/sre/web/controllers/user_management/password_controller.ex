defmodule Sre.UserManagement.PasswordController do
  use Sre.Web, :controller

  alias User.{PasswordToken, PasswordChange}
  alias Sre.Service.Email.Composer
  alias Sre.Router.Helpers

  def auth_0_update(%Plug.Conn{assigns: %{current_user: user}} = conn, params) do
    changeset =
      PasswordChange.password_changeset(params["password_change"])
    if changeset.valid? do
      case PasswordChange.update_auth0(user, params) do
        {:ok, :updated} ->
          response(conn, user)
        _ ->
          conn
          |> put_flash(:info, "Unable to update password")
          |> response(user)
      end
    else
      conn
      |> put_flash(:info, "Unable to update password")
      |> response(user, changeset)
    end
  end

  defp response(conn, user, changeset \\ PasswordChange.password_changeset(%{})) do
    redirect conn,
      to: user_management_user_path(conn, :edit),
      password_changeset: changeset,
      user_id: user.id
  end

  # GET /update_password
  # This presents a form with enter email input.
  def reset_password(conn, %{"action" => "forgot_password"}) do
    do_reset_password(conn, "forgot_password")
  end

  # GET /update_password
  # This is button that gets clicked. Simply generates the email.
  def reset_password(conn, %{"action" => "change_password"}) do
    do_reset_password(conn, "change_password")
  end

  def reset_password(conn, _) do
    do_reset_password(conn, "forgot_password")
  end

  defp do_reset_password(%{assigns: %{current_user: nil}} = conn, action) do
    conn
    |> assign(:action, String.to_atom(action))
    |> render("forgot_password.html")
  end

  defp do_reset_password(%{assigns: %{current_user: user}} = conn, _action) do
    do_request_reset(conn, user, "change_password.html")
  end

  # POST /update_password
  def request_reset(conn, %{"email_address"=> email}) do
    do_request_reset(conn, email, "thank_you.html")
  end

  defp do_request_reset(conn, param, email_template) do
    user = param
    |> PasswordToken.set_reset_password_token
    url = reset_password_url(conn, user)
    user
    |> Composer.send_reset_password_email(url)
    |> case do
      {:success, _email} ->
        # @todo: Send email confirmation here
        # We sent a reset link...content
        render conn, email_template
      {:failure, :not_on_file} ->
        conn
        |> put_flash(:info, "No account associated with that email")
        |> render(email_template)
      {:failure, _, _} ->
        # We sent a reset link...content
        render conn, email_template
    end
  end

  defp reset_password_url(conn, user) do
    Helpers.password_path(conn, :edit, %{user_id: user.id, token: user.forgot_password_token, email: user.email})
  end

  # GET /Present User Form.
  def edit(conn, %{"token" => token, "email" => email}) do
    token
    |> PasswordToken.fetch_and_validate(email)
    |> case do
      {:valid, user} ->
        conn
        |> assign(:user, user)
        |> render("update_password_form.html")
      {:expired, _user} ->
        expired_link(conn)
    end
  end

  def update(conn, %{"token" => token, "email" => email} = params) do
    token
    |> PasswordToken.fetch_and_validate(email)
    |> case do
      {:valid, user} ->
        PasswordToken.update_auth0_password(user, params)
        # case logged in - log out user and redirect to login with new password.
        render conn, "thank_you.html", message: "You will be relogged in."
      {:expired, _} ->
        expired_link(conn)
    end
  end

  defp expired_link(conn) do
    conn
    |> put_flash(:info, "Your Link has expired")
    |> redirect(to: password_path(conn, :reset_password), action: "forgot_password")
  end

end
