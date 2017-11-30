defmodule Sre.SreCookie do
  @moduledoc """
  Checks the session for either the :current_user_id set by the
  Authcontroller at login.

    if result
      true -> continue to preceding plug
      false -> execute this plug's functionality

  """
  import Plug.Conn

  alias Ecto.UUID
  alias Schema.{Resource.User, Repo}

  def init(opts), do: opts

  def call(%{assigns: %{current_guest: %User{}}} = conn, _),
    do: conn

  def call(conn, _opts) do
    conn
    |> get_session(:current_user_id)
    |> case do
      nil -> anonymous_user(conn)
      _ -> conn
    end
  end

  def anonymous_user(conn) do
    conn
    |> get_session(:anonymous_id)
    |> case do
      nil ->
        uuid = UUID.generate
        user = Repo.insert! %User{anonymous_id: uuid}
        conn
        |> session_set(user.anonymous_id)
        |> assign(:guest_user, user)
      uuid ->
        user = Repo.get_by(User, anonymous_id: uuid)
        assign(conn, :guest_user, user)
    end
  end

  defp session_set(conn, anonymous_id) do
    conn
    |> put_session(:anonymous_id, anonymous_id)
    |> configure_session(renew: true)
  end

end
