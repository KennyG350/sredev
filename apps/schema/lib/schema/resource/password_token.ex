defmodule Schema.Resource.PasswordToken do
  @moduledoc """
    User Password Token Resource -
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Schema.Repo

  alias Ecto.{UUID, DateTime}

  schema "users" do
    field :forgot_password_token
    field :forgot_password_token_expiration, DateTime
    timestamps
  end

  def changeset(struct, :reset, params \\ %{}) do
    struct
    |> cast(params, [:forgot_password_token])
    |> set_password_token
  end

  defp set_password_token(changeset) do
    changeset
    |> get_field(:forgot_password_token)
    |> case do
      nil -> set_token_and_expiration(changeset)
      _token -> changeset
    end
  end

  defp set_token_and_expiration(changeset) do
    changeset
    |> put_change(:forgot_password_token, uuid)
    |> put_change(:forgot_password_token_expiration, expire_date(3))
  end

  defp uuid, do: UUID.generate

end
