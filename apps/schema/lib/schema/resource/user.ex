defmodule Schema.Resource.User do
  @moduledoc """
  User Model
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Schema.Repo

  alias Ecto.UUID
  alias Schema.Resource.{
    Group,
    Lead,
    Search,
    UserProfile,
    UserPhone,
    UserFormMessage
  }

  schema "users" do
    has_one  :user_profile, UserProfile
    has_many :user_phones, UserPhone
    has_many :groups, Group
    has_many :created_groups, Group, foreign_key: :created_by
    has_many :saved_searches, Search
    has_many :form_messages, UserFormMessage
    many_to_many :leads, Lead, join_through: "leads_users"

    field :first_name, :string
    field :last_name, :string
    field :nickname, :string
    field :picture, :string
    field :email, :string
    field :email_verified, :boolean
    field :email_blacklisted, :boolean
    field :auth_0_id, :string
    field :anonymous_id, Ecto.UUID
    field :forgot_password_token, :string
    field :forgot_password_token_expiration, Ecto.DateTime

    field :requested_email, :string, virtual: true
    field :verify_email_token, :string
    field :verify_email_expiration, Ecto.DateTime

    field :last_login, Ecto.DateTime
    field :user_type, :string, default: "external"

    timestamps inserted_at: :created_at
  end

  def changeset(user, :change_email) do
    user
    |> cast(%{}, [:verify_email_token, :verify_email_expiration])
    |> put_change(:verify_email_token, UUID.generate)
    |> put_change(:verify_email_expiration, expire_date(30))
  end

  def changeset(user, :reset_email_token) do
    changeset(user, :change_email)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, castable)
    |> validate_required(required)
    |> unique_constraint(:email, name: :user_email_user_type)
    |> cast_assoc(:user_phones)
    |> cast_assoc(:user_profile)
  end

  def registration_changeset(%__MODULE__{} = user) do
    changeset = change(user)
    do_registration(changeset)
  end

  def registration_changeset(changeset) do
    do_registration(changeset)
  end

  defp do_registration(changeset) do
    changeset
    |> put_change(:verify_email_token, UUID.generate)
    |> put_change(:verify_email_expiration, expire_date(2))
  end

  def registration_verified(user) do
    change(user, %{email_verified: true})
  end

  defp required,
    do: Enum.filter(castable, fn i -> i == :email end)

  defp castable do
    [
      :first_name,
      :last_name,
      :nickname,
      :picture,
      :email,
      :email_verified,
      :auth_0_id,
      :last_login,
      :anonymous_id
    ]
  end

end
