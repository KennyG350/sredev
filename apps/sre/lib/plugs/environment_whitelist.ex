defmodule Sre.Plugs.EnvironmentWhitelist do
  alias Phoenix.Router.NoRouteError
  alias Sre.Router

  def init(env), do: env

  def call(conn, env) when is_atom env do
    unless Mix.env === env do
      raise NoRouteError, conn: conn, router: Router
    end

    conn
  end

  def call(conn, envs) when is_list envs do
    unless Enum.member? envs, Mix.env do
      raise NoRouteError, conn: conn, router: Router
    end

    conn
  end
end
