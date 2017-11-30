defmodule Schema.Resource.UserProfile do
  @moduledoc """
  UserProfile Model
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "user_profile" do
    belongs_to :user, Schema.Resource.User
    field :address, :string
    field :city, :string
    field :state, :string
    field :zip, :string
    field :created_at, Timex.Ecto.DateTime
    field :updated_at, Timex.Ecto.DateTime
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, allowed)
    |> validate_inclusion(:preferred_contact_method, ["phone", "email", "text"])
    |> cleanup_home_number
    |> cleanup_mobile_number
  end

  defp allowed do
    [
      :address,
      :city,
      :state,
      :zip
    ]
  end

  def cleanup_home_number(changeset) do
    do_validate_contact(changeset, :home_phone)
  end

  def cleanup_mobile_number(changeset) do
    do_validate_contact(changeset, :mobile_phone)
  end

  def do_validate_contact(changeset, key) do
    contact = get_change(changeset, key)
    do_regex_phone(contact, key, changeset)
  end

  def do_regex_phone(nil, _key, changeset), do: changeset
  def do_regex_phone(phone, key, changeset) when is_binary(phone) do
    phone = Regex.replace(~r/[^$0-9]/, phone, "")
    put_change(changeset, key, phone)
  end
end
