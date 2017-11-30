defmodule Sre.DetectRedirect do
  @moduledoc """
  Detects a "redirect" parameter in the URL and adds it to the session
  """

  import Plug.Conn
  import Sre.Router.Helpers, only: [property_path: 2]

  def init(opts), do: opts

  def call(%{params: %{"state" => state}} = conn, _opts) do
    state
    |> Poison.decode!
    |> detect_token_or_url(conn)
  end

  def call(conn, _opts), do: conn

  defp detect_token_or_url(%{"token" => _token} = token_params, conn) do
    params = %{conn.params | "state" => token_params}
    %{conn | params: params}
  end

  defp detect_token_or_url(%{"bounds" => _, "token" => _}, conn) do
    conn
  end

  defp detect_token_or_url(%{"bounds" => _} = params, conn) do
    url_path =
      params
      |> Map.keys
      |> Enum.map(fn k -> "#{k}=#{params[k]}" end)
      |> Enum.intersperse("&")
      |> Enum.reduce(&Kernel.<>/2)

    path =
       property_path(conn, :index) <> "?#{url_path}"
    new_params =
      Map.drop(conn.params, ["state"])
    conn =
      %{conn | params: new_params}
    conn
    |> put_session(:redirect, path)
    |> configure_session(renew: true)
  end

  defp detect_token_or_url(_params, conn), do: conn
end
