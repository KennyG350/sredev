defmodule User.Management do
  @moduledoc """
  Functions for managing users
  """
  use User.Http.Auth0

  require Ecto.Query

  alias User.Http.Auth0

  alias Ecto.{Changeset, DateTime, Query, UUID}

  alias Schema.{
    Repo,
    Resource.User,
    Resource.UserPhone,
    Resource.UserProfile,
  }

  # alias Sre.Service.Email.Delivery

  def get_user_by_anon_id(anon_id) do
    case Repo.get_by(User, anonymous_id: anon_id) do
      nil -> {:error, :no_user_found}
      user -> {:ok, user}
    end
  end

  def get_user_by_auth0_profile(%{uid: uid} = auth) do
    User
    |> Query.preload([:user_profile])
    |> Query.where([u], u.auth_0_id == ^uid)
    |> Query.where([u], u.user_type == "external")
    |> Repo.one
    |> case do
      nil ->
        lookup_and_update(auth)
      user ->
        {:ok, user}
     end
  end

  defp lookup_and_update(%{info: %{email: email}, uid: auth_id} = auth) do
    user = User
    |> Query.where([u], u.email == ^email)
    |> Query.where([u], u.user_type == "external")
    |> Repo.one

    case user do
      nil -> {:error, :no_user_found}
      user ->
        user =
          user
          |> Changeset.change(%{auth_0_id: auth_id})
          |> Repo.update!
        {:ok, user}
    end
  end

  def create_new_user(strategy, params \\ %{})

  def create_new_user(:params, params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert!
  end

  def create_new_user(:auth0_profile, auth0_profile) do
    %User{}
    |> User.changeset(build_user(%User{}, auth0_profile))
    |> User.registration_changeset
    |> Repo.insert!
  end

  def update(user, %{"user_phones" => %{"0" => %{"phone_number" => ""}}} = user_params) do
    user
    |> update(Map.drop(user_params, ["user_phones"]))
  end

  def update(user, user_params) do
    user_params = set_user_phone_to_primary(user_params)
    user
    |> Repo.preload(:user_profile)
    |> Repo.preload(user_phones: UserPhone |> Query.where(is_primary: true, user_id: ^user.id))
    |> User.changeset(user_params)
    |> email_update_requested?
  end

  def add_user_phones(%User{user_phones: user_phones} = user, phone_number, opts \\ []) do
    case Enum.any? user_phones, & phone_remove_leading_one(&1.phone_number) == phone_number do
      true ->
        user
      false ->
        do_add_user_phones user, phone_number, opts
    end
  end

  def do_add_user_phones(%User{user_phones: user_phones} = user, phone_number, opts \\ []) do
    primary? = Keyword.get opts, :primary?, false
    new_phone = new_user_phone(phone_number, primary?: primary?)

    user_phones =
      case primary? do
        true ->
          user_phones
          |> Enum.map(fn phone ->
              phone
              |> UserPhone.changeset(%{is_primary: false})
             end)
        _ ->
          user_phones
          |> Enum.map(&UserPhone.changeset/1)
    end

    user
    |> User.changeset
    |> Changeset.put_assoc(:user_phones, [new_phone | user_phones])
  end

  def new_user_phone(phone_number, opts \\ []) do
    primary? = Keyword.get opts, :primary?, false
    phone_changeset =
      %UserPhone{}
      |> UserPhone.changeset(%{phone_number: phone_number, is_primary: primary?})
  end

  def email_update_requested?(changeset) do
    changeset
    |> Changeset.get_change(:email, false)
    |> case do
      false ->
        changeset |> Repo.update
      email when is_binary(email) ->
        # Delivery.send_verify_email(changeset, email)
    end
  end

  def update_user(user, params) do
    update(user, build_user(user, params))
  end

  def update_profile(user, user_profile_params) do
    user
    |> Ecto.assoc(:user_profile)
    |> Repo.one
    |> case do
      nil ->
       user
       |> Ecto.build_assoc(:user_profile)
       |> UserProfile.changeset(user_profile_params)
       |> Repo.insert
      profile ->
        val = UserProfile.changeset(profile, user_profile_params)
        val |> Repo.update
    end
  end

  def generate_anonymous_id, do: UUID.generate

  def fetch_auth0_user(auth_0_id) do
    url = "https://#{base_url}/api/v2/users/#{auth_0_id}"
    headers = [{"Content-Type", "application/json"}] ++ headers(access_token)
    url
    |> Auth0.get(headers)
    |> case do
      {:ok, %{status_code: 200, body: body}} ->
        Poison.decode!(body)

      {:ok, %{status_code: status_code, body: body}} ->
        response = Poison.decode!(body)
        raise "Could not fetch Auth0 user to extract first and last name. "
          <> "Status code: #{status_code}. "
          <> "Message: #{response["message"]}"
    end
  end

  defp build_user(user, profile) do
    data =
      %{first_name: profile.info.first_name,
        last_name: profile.info.last_name,
        nickname: profile.info.nickname,
        email: profile.info.email,
        auth_0_id: profile.uid,
        picture: profile.info.image,
        email_verified: false,
        last_login: DateTime.utc}

    data = data |> ensure_name_set(profile)
  end

  defp ensure_name_set(%{first_name: nil, last_name: _} = data, %{uid: auth_id}) do
    case fetch_auth0_user(auth_id) do
      %{"user_metadata" => %{"first_name" => fname, "last_name" => lname}} = response ->
          %{data | first_name: fname, last_name: lname}
    end
  end

  defp ensure_name_set(data, _), do: data

  defp set_user_phone_to_primary(%{"user_phones" => _} = user_params) do
    updated_phone = Map.put user_params["user_phones"]["0"], "is_primary", true
    put_in(user_params["user_phones"]["0"], updated_phone)
  end

  defp set_user_phone_to_primary(user_params), do: user_params

  defp phone_remove_leading_one(phone) do
    phone
    |> String.split("", trim: true)
    |> Enum.drop(1)
    |> Enum.join("")
  end
end
