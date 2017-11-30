defmodule Schema.Resource.UserPhone do
  @moduledoc """
  User Phones Model
  """
  @regx ~r/(\d{10})|^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_phones" do
    belongs_to :user, Schema.Resource.User
    field :phone_number, :string
    field :label, :string
    field :is_primary, :boolean
    field :phone_extension, :string
  end

  def changeset(user_phone, params \\ %{}) do
    user_phone
    |> cast(params, [:phone_number, :label, :is_primary, :phone_extension])
    |> validate_required([:phone_number])
    |> validate_length(:phone_extension, max: 30)
    |> validate_phone_number
  end

  def validate_phone_number(changeset) do
    case get_change(changeset, :phone_number) do
      nil -> changeset
      number -> formatted?(number, changeset)
    end
  end

  defp formatted?(number, changeset) do
    if Regex.match?(@regx, number) do
      numbers = Regex.replace(~r/[^\d]/, number, "")
      put_change(changeset, :phone_number, "1#{numbers}")
    else
      changeset |> add_error(:phone_number, "Invalid phone number format")
    end
  end

end
