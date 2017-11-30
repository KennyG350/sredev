defmodule User.PasswordToken do
  @moduledoc """
  Service that handles how User has Password Tokens are fetched generated.
  """
  use User.Http.Auth0

  alias User.Http.Auth0

  alias Schema.{
    Repo,
    Resource.PasswordToken,
    Resource.User
  }
  alias Ecto.DateTime

  def set_reset_password_token(email)
  when is_binary(email) do
    user = fetch_by_email(email)
    user
    |> case do
      nil -> nil
      user -> set_reset_password_token(user)
    end
  end

  def set_reset_password_token(user) do
    user
      |> PasswordToken.changeset(:reset)
      |> Repo.update!
  end

  def fetch_by_email(email) when is_binary(email) do
    Repo.get_by(User, %{email: email})
  end

  def fetch_and_validate(token, email) do
    user = Repo.get_by(User, %{email: email, forgot_password_token: token})
    if expired?(user) do
      {:valid, user}
    else
      {:expired, user}
    end
  end

  defp expired?(%{forgot_password_token_expiration: expire_date}) do
    now = :calendar.universal_time |> DateTime.from_erl
    now < expire_date
  end

  def update_auth0_password(%{auth_0_id: auth_0_id}, %{"password" => password}) do
    url = "https://#{base_url}/api/v2/users/#{auth_0_id}"
    Auth0.patch(url, json_body(password), headers(access_token))
  end

  def update_auth0_password(_, _), do: nil

  defp json_body(passw), do: Poison.encode!(%{password: passw})

end
