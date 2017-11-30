defmodule Sre.UserManagement.EmailController do
  use Sre.Web, :controller

  use Sre.Controller

  plug Sre.RequireLogin when action in [:edit, :update]

  alias Schema.{Repo, Resource.User}
  alias Sre.Service.Email.Delivery
  alias Sre.Tokenizer

  def edit(conn, %{"user_id" => _user_id}, user) do
    render conn, "edit_email.html", changeset: User.changeset(user)
  end

  def update(conn, %{"email" => email}, user) do
    Delivery.send_verify_email(user, email, conn)
    render conn, "email_submitted.html"
  end

  def verify(conn, %{"token" => token, "requested_email" => email}, _) do
    case Tokenizer.fetch_and_validate(token) do
      {:valid, user} ->
        user
        |> User.changeset(%{email: email})
        |> Repo.update
        render conn, "verified.html", message: true
      {:expired, _user} ->
        conn
        |> put_flash(:info, "Your email verify link expired.")
        render conn, "verified.html", message: false
    end
  end

end
