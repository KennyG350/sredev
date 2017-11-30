defmodule User.PasswordChange do
  use Ecto.Schema

  use User.Http.Auth0

  alias User.{
    PasswordToken,
    Http.Auth0
  }

  import Ecto.Changeset, only: [
    cast: 3,
    validate_confirmation: 2,
    validate_required: 2
  ]

  embedded_schema do
    field :current
    field :password
    field :password_confirmation
  end

  def password_changeset(changes) do
    User.PasswordChange
      |> struct
      |> cast(changes, [:current, :password, :password_confirmation])
      |> validate_required([:current, :password, :password_confirmation])
      |> validate_confirmation(:password)
  end

  def update_auth0(user, %{"password_change" => params} = pass_params) do
    data =
      %{
        client_id: client_id,
        username: user.email,
        password: params["current"],
        connection: "Username-Password-Authentication",
        grant_type: "password",
        scope: "openid name email"
      }
    url = "https://#{base_url}/oauth/ro"
    url
    |> Auth0.post(json_body(data), [{"Content-Type", "application/json"}])
    |> do_update_password(user, params)
  end

  def do_update_password(%{status_code: 200} = response, user, params) do
    update_auth0_password(user, %{"password" => params["password"]})
    {:ok, :updated}
  end

  def update_auth0_password(%{auth_0_id: auth_0_id}, payload) do
    url  = "https://#{base_url}/api/v2/users/#{auth_0_id}"
    body = Poison.encode!(payload)
    update_headers = [{"Content-Type", "application/json"}] ++ headers(access_token)
    Auth0.patch(url, body, update_headers)
  end

  def do_update_password(%{status_code: code} = response, _user, _params)
  when code >= 400 and code <= 500 do
    {:error, :not_updated}
  end

  defp json_body(data) do
    Poison.encode!(data)
  end

end
