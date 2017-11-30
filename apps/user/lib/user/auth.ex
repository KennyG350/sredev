defmodule User.Auth do
  @moduledoc """
  Fetches the `current_user` key from the session.

  ## Session
  """
  import Plug.Conn

  alias Schema.{Repo, Resource.User}

  def init(opts \\ []), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)

    end
  end
end
