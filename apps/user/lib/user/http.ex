defmodule User.Http.Auth0 do
  @moduledoc """
  A light wrapper around the Auth0 Api
  """

  defmacro __using__(_) do
    quote do
      defdelegate headers(token), to: User.Http.Auth0
      defdelegate access_token, to: User.Http.Auth0
      defdelegate base_url, to: User.Http.Auth0
      defdelegate client_id, to: User.Http.Auth0
      defdelegate patch(url, body, headers), to: User.Http.Auth0
    end
  end

  def base_url do
    Application.get_env(:user, :auth_domain)
  end

  def access_token do
    Application.get_env(:user, :client_user_jwt)
  end

  def client_id do
    Application.get_env(:user, :client_id)
  end

  def headers(token) do
    [{"Authorization", "Bearer #{token}"}]
  end

  def get(url, headers, options \\ []) do
    HTTPoison.get(url, headers, options)
  end

  def patch(url, body, headers) do
    HTTPoison.request!(:patch,
      url,
      body,
      headers,
      timeout: 20_000,
      recv_timeout: 20_000)
  end

  def post(url, body, headers \\ []) do
    HTTPoison.request!(:post,
      url,
      body,
      headers,
      timeout: 20_000,
      recv_timeout: 20_000)
  end

end
