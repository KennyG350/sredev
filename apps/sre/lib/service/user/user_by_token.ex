defmodule Sre.UserByToken do

  @moduledoc """
  Service that handles - capturing the user
  record via the token - and updating email_verified flag.
  """

  use Ecto.Schema
  import Ecto.Changeset, only: [cast: 3, put_change: 3]

  alias Schema.Repo

  schema "users" do
    field :anonymous_id, Ecto.UUID
    field :email_verified, :boolean
  end

  def mark_email_as_verified(token) do
    __MODULE__
    |> Repo.get_by(anonymous_id: token)
    |> case do
      nil -> nil
      record -> update(record)
    end
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email_verified])
  end

  defp update(record) do
    record
    |> changeset
    |> put_change(:email_verified, true)
    |> Repo.update!
  end

end
