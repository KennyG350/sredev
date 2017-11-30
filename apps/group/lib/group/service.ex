defmodule Group.ListingService do
  @moduledoc """
  A service for providing an api for other applications to use to manage
  a user group
  """
  import Ecto.Query, only: [select: 3]

  alias Schema.Repo
  alias Group.Query
  alias Schema.Resource.{
    Group,
    User,
    Listing
  }

  @doc """
  fetch_by_user_id/1 takes an user id and gets all the groups for the user

  This is useful when you want to this the groups the user has
  """

  def fetch_by_user_id(user_id) do
    Group
    |> select([g], g)
    |> Query.for_user(user_id)
    |> Repo.all
  end

  @doc """
  fetch_by_user_id_and_name/2 takes a user id and name and gets a group for that user with the name
  """
  def fetch_by_user_id_and_name(user_id, name) do
    Group
    |> select([g], g)
    |> Query.for_user(user_id)
    |> Query.with_name(name)
    |> Repo.one
    |> Repo.preload([listings: :photos, listings: :groups])
  end

  @doc """
  delete_group/1 deletes a group

  This is useful for when a user wants to delete a group from there group list
  """

  def delete_group(group_id) do
     Group
     |> Repo.get!(group_id)
     |> Repo.delete
  end

  @doc """
  add_listing/2 takes a group id or group resource and listing id and associates them together

  This is useful for when a user wnats to favorite or put a listing into a group
  """

  def add_listing(group_id, listing_id) when is_binary(group_id) or is_integer(group_id) do
    group =
      Group
      |> Repo.get!(group_id)
      |> Repo.preload(:listings)

    listing =
      Listing
      |> Repo.get!(listing_id)

    group =
      group
      |> Query.build_assoc(listing)
      |> Repo.update!

    {:ok, listing, group}
  end

  def add_listing(%Group{} = group, listing_id) do
    listing =
      Listing
      |> Repo.get!(listing_id)

    group
    |> Repo.preload(:listings)
    |> Query.build_assoc(listing)
    |> Repo.update!

    {:ok, listing, group}
  end

  @doc """
  get_group_with_listings/1 gets a grups with the listings preloaded by `group_id`

  useful when querying to get a group by id
  """
  def get_group_with_listings(group_id) do
     Group
     |> Repo.get!(group_id)
     |> Repo.preload(:listings)
  end

  @doc """
  get_group_with_listings/2 gets a group for a particular user.

  This is useful when you want to be sure that a user can only see their groups.
  """

  def get_group_with_listings(group_id, user_id) do
    Group
    |> select([g], g)
    |> Query.for_user(user_id)
    |> Repo.get!(group_id)
    |> Repo.preload(:listings)
  end

  @doc """
  remove_listing/1 takes a group id and a listing id and removes the association between the group and the listing

  This is useful for when a user decides they do not want a listing as part of a group anymore
  """

  def remove_listing(group_id, listing_id) do
    Group
    |> do_remove_listing(group_id, listing_id)
  end

  def remove_listing_for_user(%User{} = user, group_id, listing_id) do
    user
    |> Query.assoc_user_groups
    |> do_remove_listing(group_id, listing_id)
  end

  def remove_listing_for_user(%{} = user, group_id, listing_id) do
    User
    |> Repo.get!(user.id)
    |> Query.assoc_user_groups
    |> do_remove_listing(group_id, listing_id)
  end

  ## Helpers

  defp do_remove_listing(query, group_id, listing_id) do
     query
     |> Repo.get!(group_id)
     |> Repo.preload(:listings)
     |> Query.remove_listing_from_group(listing_id)
     |> Repo.update
  end
end
