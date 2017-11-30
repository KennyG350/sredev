defmodule User.ActivitiesTest do
  use ExUnit.Case
  import Ecto.Query

  alias User.Activity, as: Service
  alias User.Search
  alias Schema.{
    Repo,
    Connection,
    Resource.User
  }

  setup do
    Connection.share_db_connection self

    user =
      %User{
        first_name: "steve",
        last_name: "bob",
        picture: "pic url",
        email: "steve@test.com",
        email_verified: true,
        auth_0_id: "google-oauth|100"
      }
      |> Repo.insert!

    listing =
      %Schema.Resource.Listing{
        rets_id: "1231231",
        feed_id: 1,
        is_valid: true,
        url: "google.com",
        city: "kajsdflja",
        state: "AZ",
        zip_code: "90909",
        street_number: "123",
        street_name: "sajdfljaldsjf"
      }
      |> Repo.insert!

      {:ok, _search, user} =
        user.id
        |> Search.save_user_search("fake test search", %{hello: "world"})

    {:ok, user: user, listing: listing, search: Enum.at(user.saved_searches, 0)}
  end

  test "viewed_listing/2 will save a viewed lisitng to to the user_activies table", %{user: user, listing: listing} do
    Service.viewed_listing user.id, listing.url
    :timer.sleep 500
    [activity|_] =
      listing.id
      |> get_activity_entity
      |> Repo.all
    assert activity.entity_id == listing.id
  end

  test "saved_search/1 will save the activity for when a user saves a search", %{search: search} do
    Service.saved_search search
    :timer.sleep 500
    [activity|_] =
      search.id
      |> get_activity_entity
      |> Repo.all
    assert activity.entity_id == search.id
  end

  test "saved_listing/2 will save the activity for when a user saves a listing", %{listing: listing, user: user} do
    Service.saved_listing listing, user.id
    :timer.sleep 500
    [activity|_] =
      listing.id
      |> get_activity_entity
      |> Repo.all
    assert activity.entity_id == listing.id
  end

  defp get_activity_entity(entity_id) do
    from a in "user_activities",
      select: [:entity_id],
      where: a.entity_id == ^entity_id
  end
end
