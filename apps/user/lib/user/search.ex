defmodule User.Search do
  @moduledoc """
  Service for working with user saved searches
  """
  import Ecto.Query
  import Ecto

  alias Ecto.Changeset
  alias User.{
    Query
  }
  alias Schema.Repo
  alias Schema.Resource.{
    Search,
    User
  }

  def fetch_by_user_id(user_id) do
    Search
    |> select([s], s)
    |> Query.for_user(user_id)
    |> Repo.all
  end

  @doc """
  save_user_search/2 given some `user_id` and some a map of `params` associate a search and search attributes
  to the user.
  """
  def save_user_search(user_id, search_name, search_params \\ %{}) do
    user = get_user user_id
    search =
      user
      |> build_assoc(:saved_searches)
      |> Search.changeset(%{name: search_name, saved: true, created_by: user.id})
      |> Search.changeset(%{hash: hash_search_params(search_params)})
      |> Query.assoc_attributes(search_params)
      |> Repo.insert!

    {:ok, search, user}
  end

  @doc """
  delete_search/2 finds a saved searched by for a user by `search_id`
  """
  def delete_search(user_id, search_id) do
    Search
    |> select([s], s)
    |> Query.for_user(user_id)
    |> Repo.get!(search_id)
    |> Repo.delete!
  end

  def hash_search_params(search \\ %{})  do
    search_filters = search
    |> URI.encode_query
    |> String.split("&", trim: true)
    |> Enum.map(fn query ->
        case String.contains? query, "location" do
          true ->
            URI.decode(query)
          false ->
            query
        end

       end)
    |> Enum.filter(fn query ->
        !(String.contains?(query, "bounds") || String.contains?(query, "page") || Regex.match?(~r/\w+=$/, query))
       end)
    |> Enum.join

    :md5
    |> :crypto.hash(search_filters)
    |> Base.encode64
  end

  def get_searches_by_user_id(user_id) do
    user_id
    |> get_searches_by_user_id_query
    |> preload(:search_attributes)
    |> Repo.all
  end

  def get_searches_by_user_id_query(user_id) do
    from s in Search,
      select: [:name, :id],
      where: s.user_id == ^user_id
  end

  def get_user_search_hash(_hash, nil), do: nil
  def get_user_search_hash(hash, %User{id: user_id}) do
    hash
    |> do_get_user_search_hash(user_id)
  end

  def get_user_search_hash(hash, user_id) do
    hash
    |> do_get_user_search_hash(user_id)
  end

  defp do_get_user_search_hash(hash, user_id) do
    user_id
    |> get_searches_by_user_id_query
    |> where_hash(hash)
    |> Repo.one
  end

  def where_hash(query, hash) do
    query
    |> where([s], s.hash == ^hash)
  end

  ## Helpers
  defp get_user(user_id), do: User |> Repo.get!(user_id) |> Repo.preload(:saved_searches)

  def create_search(user, search_name, search_params) do
    %Search{}
    |> Search.changeset(%{name: search_name, saved: true})
    |> Changeset.put_assoc(:created_by_user, user)
    |> Query.assoc_attributes(search_params)
    |> Repo.insert!
  end

end
