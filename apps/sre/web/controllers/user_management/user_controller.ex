defmodule Sre.UserManagement.UserController do

  use Sre.Web, :controller
  use Sre.Controller

  plug Sre.RequireLogin
  alias Ecto.Changeset
  alias User.{Management, PasswordChange, Query}
  alias Schema.{
    Resource.User,
    Resource.UserPhone,
    Repo
  }

  def edit(conn, _, user) do
    user = Repo.preload(user, [:user_profile, user_phones: Query.user_phones_preload_query(user)])

    changeset =
      user
      |> User.changeset
      |> Changeset.put_assoc(:user_phones, user_phones(user.user_phones))

    render conn, "edit.html",
      changeset: changeset,
      password_changeset: PasswordChange.password_changeset(%{}),
      user_id: user.id
  end

  def update(conn, params, user) do
    with {:ok, user}     <- Management.update(user, params["user"]),
         {:ok, _profile} <- Management.update_profile(user, params["user"]["user_profile"])
    do
      case user.requested_email do
        true ->
          conn
          |> put_flash(:notice, "We sent a verification email to the email requested.")
          |> response(user)
        _ ->
          response(conn, user)
      end
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Unable to update user profile")
        |> redirect(to: user_management_user_path(conn, :edit))

      :error -> redirect conn, to: user_management_user_path(conn, :edit)
    end
  end

  defp response(conn, user) do
    redirect conn, to: user_management_user_path(conn, :edit),
        changeset: User.changeset(user, %{}), user_id: user.id
  end

  defp user_phones([]) do
    [%UserPhone{} |> UserPhone.changeset]
  end

  defp user_phones(phones) do
    phones
    |> Enum.map(fn phone ->
        UserPhone.changeset(phone)
       end)
  end

end
