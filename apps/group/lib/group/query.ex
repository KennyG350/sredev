defmodule Group.Query do
  @moduledoc """
  Group.Query is a module for building up a query to be ran by a repo for groups

  None of these functions make calls to the outside world (htt, to disk, to database).
  these should only be used to build up a query to be ran by a repo.
  """
  import Ecto.Query, only: [from: 2]

  alias Ecto.Changeset

  @doc """
  for_user/1 takes a group query and user id, and returns a query that
  should only return the groups for that user.

  This is useful for composing query together where you only want a certain users
  groups

  """
  def for_user(query, user_id) do
    from g in query,
      join: u in assoc(g, :user),
      where: u.id == ^user_id
  end

  def with_name(query, name) do
    from g in query,
      where: g.name == ^name
  end

  @doc """
  build_assoc/2 takes a group record and a listing record, and builds the query for
  the assocation

  This is useful for when there a group and a listing which belongs to the group
  """

  def build_assoc(group, %Schema.Resource.Listing{} = listing) do
    listings = group.listings ++ [listing]
    do_build_assoc group, listings
  end

  @doc """
  remove_listing_from_group/2 takes a group and a listing id and builds the query
  for removing the listing from the group

  This is useful when building a query that involves removeing an assocation
  between a listing and a group.
  """

  def remove_listing_from_group(group, listing_id) when is_binary(listing_id) do
    listings =
      listing_id
      |> String.to_integer
      |> filter_out_listing(group.listings)

    do_build_assoc(group, listings)
  end

  def remove_listing_from_group(group, listing_id) do
    listings = filter_out_listing(listing_id, group.listings)
    do_build_assoc(group, listings)
  end

  def assoc_user_groups(user), do: Ecto.assoc(user, :groups)

  defp do_build_assoc(group, listings) do
    group
    |> Changeset.change
    |> Changeset.put_assoc(:listings, Enum.map(listings, &Changeset.change/1))
  end

  defp filter_out_listing(listing_id, listings) do
    Enum.filter listings, fn listing ->
      listing.id !== listing_id
    end
  end
end
