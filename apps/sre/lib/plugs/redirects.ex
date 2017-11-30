defmodule Sre.Redirects do
  import Plug.Conn

  alias Phoenix.Controller

  def init(options), do: options

  def call(%Plug.Conn{request_path: path} = conn, options), do: conn |> do_redirect(options[path])

  defp do_redirect(conn, nil), do: conn
  defp do_redirect(conn, to) do
    conn
    |> Controller.redirect(to: to)
    |> halt
  end
end
