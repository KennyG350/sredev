defmodule Sre.SessionController do
  use Sre.Web, :controller

  alias Sre.UserByToken

  def new(conn, _params) do
    render conn, "new.html"
  end

  def invite(conn, %{"token" => token}) do
    UserByToken.mark_email_as_verified(token)
    conn
    |> redirect(to: "/?token=" <> token)
  end
end
