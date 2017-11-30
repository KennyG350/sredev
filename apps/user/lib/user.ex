defmodule User do
  @moduledoc """
  Conveniences for fetching property data from the database
  """
  use Application

  import Ecto.Query

  alias Schema.Repo
  alias Schema.Resource.User, as: UserResource
  alias Schema.Resource.UserPhone
  alias User.Query

  # Start application
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(User.Activity, [])
    ]

    opts = [strategy: :one_for_one, name: User.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_user_by_id(user_id) do
    UserResource
    |> Repo.get(user_id)
  end

  def preload(%UserResource{} = user, preloads) do
    user
    |> Repo.preload(preloads)
  end

  def get_by_email_and_type(email, :external = type) do
    email
    |> do_get_by_email_and_type(type)
    |> Repo.one
  end

  def get_by_email_and_type(email, :internal = type) do
    email
    |> do_get_by_email_and_type(type)
    |> Repo.one
  end

  def do_get_by_email_and_type(email, type) do
    type = Atom.to_string type
    UserResource
    |> where(email: ^email, user_type: ^type)
  end

  def get_user_primary_phone(nil), do: nil
  def get_user_primary_phone(%UserResource{} = user) do
    user
    |> Repo.preload(user_phones: Query.primary_phone)
  end

  def changeset(user, params \\ %{}) do
    UserResource.changeset(user, params)
  end

  def update(user_changeset), do: user_changeset |> Repo.update
end
