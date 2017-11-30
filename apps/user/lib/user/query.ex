defmodule User.Query do
  @moduledoc """
  Query building untils for pure query building on user records
  """
  import Ecto.Query, only: [from: 2, where: 2]

  alias Ecto.Changeset
  alias Schema.Resource.{
    SearchAttribute,
    UserPhone
  }

  @doc """
  for_user/1 takes a user query and user id, and returns a query that
  should only return the groups for that user.
  """

  def for_user(query, user_id) do
     from s in query,
       join: u in assoc(s, :user),
       where: u.id == ^user_id
  end

  @doc """
  assoc_attributes/2 takes a search changeset and so seach parameters and bulids the search
  """
  def assoc_attributes(search, params) do
    search
    |> Changeset.put_assoc(:search_attributes, create_search_attributes(params))
  end

  @doc """
  create_search_attributes/1 creats search attributes changesets from params
  """
  def create_search_attributes(params) do
    params
    |> Map.keys
    |> Enum.map(fn key ->
        create_search_attribute(key, params[key])
       end)
  end

  @doc """
  create_search_attribute/2 takes the key and value and builds the changeset for a search attribute
  """
  def create_search_attribute(key, value) when is_atom(key) do
    key
    |> Atom.to_string
    |> create_search_attribute(value)
  end

  def create_search_attribute(key, value) do
    {:ok, value} = Poison.encode(value)
    {:ok, key} = Poison.encode(key)
    %SearchAttribute{}
    |> SearchAttribute.changeset(%{attribute_key: key, attribute_values: value})
  end

  @doc """
  assoc_search_to_user/2 takes a user Ecto Record and assocaites searches to the user

  This will replace any old searches, so be sure to append a new search to the old searchs before
  passing the data to this function
  """
  def assoc_search_to_user(user, searches) do
    user
    |> Changeset.change
    |> Changeset.put_assoc(:saved_searches, Enum.map(searches, &Changeset.change/1))
  end

  def primary_phone do
    UserPhone
    |> where(is_primary: true)
  end

  def user_phones_preload_query(user) do
    from up in UserPhone,
      where: up.is_primary == true and up.user_id == ^user.id
  end
end
