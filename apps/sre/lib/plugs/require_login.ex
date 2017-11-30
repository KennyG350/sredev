defmodule Sre.RequireLogin do

  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import Sre.Router.Helpers, only: [session_path: 3]

  def init(opts), do: opts

  def call(%{assigns: %{current_user: user}} = conn, _opts)
  when user != nil do
    conn
  end

  def call(conn, _opts) do
    conn
    |> put_flash(:error, "You don't have permission to view that page.")
    |> redirect(to: session_path(conn, :new, []))
    |> halt
  end
end
