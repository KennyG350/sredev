defmodule Sre.UserIp do
  import Plug.Conn

  alias Sre.UserLocation

  def init(opts), do: opts

  def call(conn, _opts) do
    case UserLocation.from_ip conn.remote_ip do
      {:ok, location} ->
        assign(conn, :user_location, location)
      {:error, _} ->
        assign(conn, :user_location, %UserLocation{})
    end
  end
end
