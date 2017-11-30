defmodule Sre.Plugs.EnforceDomain do
  import Plug.Conn

  alias Phoenix.Controller

  def init(options) do
    options
  end

  def call(conn, _options) do
    url = Application.get_env(:sre, Sre.Endpoint)[:url]
    if url[:host] === conn.host || Mix.env === :dev do
      conn
    else
      conn
      |> Controller.redirect(external: "#{conn.scheme}://#{url[:host]}:#{conn.port}")
      |> halt
    end
  end
end
