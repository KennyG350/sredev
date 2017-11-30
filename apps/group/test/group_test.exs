defmodule GroupTest do
  use ExUnit.Case
  import Ecto.Query, only: [select: 3]

  alias Group.ListingService, as: Service
  alias Schema.Repo
  alias Schema.Connection
  alias Schema.Resource.{User}

  doctest Group

  describe "Interface between Group and Listing" do
    setup do
      test_setup
    end

    test "for_user/2 builds the Ecto.Query for joining a user" do
      %Ecto.Query{joins: joins} = Schema.Resource.Group |> select([g], g) |> Group.Query.for_user(2)

      assert Enum.all?(joins, &user_joins?/1)
    end
  end

  describe "Interface between Group and Listing " do
    setup do
      test_setup
    end

    test "delete_group/1 delete group", %{group: group} do
      assert {:ok, _} = Service.delete_group(group.id)
    end

    test "fetch_by_user_id/1 gets all groups for a user", %{user: user} do
      group = Service.fetch_by_user_id user.id
      Enum.map(group, fn g -> assert %Schema.Resource.Group{} = g end)
    end

    test "add_listing/2 adds a listing to a group", %{group: group, listing: listing} do
      {:ok, _, group} = Service.add_listing group.id, listing.id

      assert Enum.any?(group.listings, fn l ->
        l.id == listing.id
      end)
    end

    test "get_group_with_listings/1 gets the group with the listings preloaded", %{group: group} do
      group = Service.get_group_with_listings group.id
      assert is_list(group.listings)
    end

    test "remove_listing/2 removes a listing from a group", %{group: group, listing: listing} do
      {:ok, listing, group} = Service.add_listing group.id, listing.id

      assert Enum.any?(group.listings, fn l ->
        l.id == listing.id
      end)

      {:ok, group} = Service.remove_listing group.id, listing.id

      refute Enum.any?(group.listings, fn l -> l.id == listing.id end)
    end
  end

  defp test_setup do
    Connection.share_db_connection self

    user =
      %User{
        first_name: "Adam",
        last_name: "Ruinseverything",
        picture: "pic url",
        email: "steve@test.com",
        email_verified: true,
        auth_0_id: "google-oauth|100"
      }
      |> Repo.insert!

    group =
      %Schema.Resource.Group{name: "fake group", user_id: user.id, created_by: user.id}
      |> Repo.insert!

    listing =
      %Schema.Resource.Listing{
        rets_id: "1231231",
        feed_id: 1,
        is_valid: true,
        url: "google.com",
      }
      |> Repo.insert!

    {:ok, group: group, user: user, listing: listing}
  end

  defp user_joins?(%Ecto.Query.JoinExpr{assoc: {_, :user}}), do: true
  defp user_joins?(%Ecto.Query.JoinExpr{assoc: {_, _}}), do: false
end
