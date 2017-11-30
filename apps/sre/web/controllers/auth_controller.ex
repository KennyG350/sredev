defmodule Sre.AuthController do
  use Sre.Web, :controller

  plug Ueberauth
  plug Sre.DetectRedirect

  # alias Sre.Service.Email.Composer # Uncomment when re-enabling registration email
  alias User.Management

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _auth}} = conn, _params) do
    conn
    |> redirect(to: "/?login_error=true")
  end
  def callback(conn, %{"state" => %{"token" => anonymous_id}}) do
      %{ueberauth_auth: auth} = conn.assigns
      anonymous_id
      |> Management.get_user_by_anon_id
      |> case do
        {:ok, user} ->
          {:ok, user} =
            Management.update_user(user, auth)
          conn |> valid_redirect(user)
        {:error, _} ->
          user =
            Management.create_new_user(:auth0_profile, auth)
          conn |> valid_redirect(user)
      end
  end
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Management.get_user_by_auth0_profile(auth) do
      {:error, :no_user_found} ->
        user = Management.create_new_user(:auth0_profile, auth)
        # url = registration_url(conn, :verify, user.verify_email_token)
        # Composer.send_registration_email(user, url)
        conn |> valid_redirect(user)
      {:ok, user} ->
        conn |> valid_redirect(user)
    end
  end

  defp valid_redirect(conn, user) do
    path = get_session(conn, :redirect) || page_path(conn, :index)
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
    |> redirect(to: path)
  end
end
