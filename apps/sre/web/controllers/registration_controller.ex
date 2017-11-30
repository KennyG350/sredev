defmodule Sre.RegistrationController do
  use Sre.Web, :controller

  alias Schema.{Repo, Resource.User}
  alias Sre.Service.Email.Composer
  alias Sre.Tokenizer

  def verify(conn, %{"token" => token}) do
    user = Repo.get_by(User, verify_email_token: token)
    case user do
      nil ->
        conn
        |> put_flash(:info, "This link is not valid.")
        |> redirect(to: page_path(conn, :index))
      user ->
        user.verify_email_token
        |> Tokenizer.fetch_and_validate
        |> response(conn)
      end
    end

    defp response({:valid, user}, conn) do
      user
        |> User.registration_verified
        |> Repo.update!
      conn
        |> put_flash(:info, "Your account has been verified")
        |> redirect(to: user_management_user_path(conn, :edit, user))
    end

    defp response({:expired, user}, conn) do
      user =
        user
        |> User.changeset(:reset_email_token)
        |> Repo.update!
      url =
        registration_url(conn, :verify, user.verify_email_token)
        Composer.send_registration_email(user, url)
      conn
        |> put_flash(:info, message(:invalid))
      |> redirect(to: page_path(conn, :index))
    end

    defp message(:invalid) do
      "Unfortunately your verification link has expired," <>
      " we sent a new one to you. Please check your email for the new link."
    end

end
