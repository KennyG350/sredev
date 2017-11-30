defmodule User.SearchTest do
  use ExUnit.Case

  alias User.{
    Search
  }
  alias Schema.Resource.User, as: UserModel
  alias Schema.Resource.Search, as: SearchModel
  alias Schema.{
    Connection,
    Repo
  }

  setup do
    Connection.share_db_connection self

    user =
      %UserModel{
        first_name: "steve",
        last_name: "scuba",
        picture: "pic url",
        email: "steve@test.com",
        email_verified: true,
        auth_0_id: "google-oauth|100"
      }
      |> Repo.insert!

    search =
      %SearchModel{name: "fake search", user_id: user.id, created_by: user.id, anonymous_id: nil}
      |> Repo.insert!

    {:ok, user: user, search: search}
  end

  test "fetch_by_user_id/1 will get the searches by a user's id", %{user: user} do
    searches = Search.fetch_by_user_id user.id

    assert Enum.all?(searches, fn search ->
            s = Repo.preload(search, :user)
            s.user.id == user.id
           end)
  end

  test "save_user_search/3 takes `user_id`, `search_name`, and `search_params` and saves a search" do
    user =
      %UserModel{
        first_name: "steve",
        last_name: "scuba",
        picture: "pic url",
        email: "b@test.com",
        email_verified: true,
        auth_0_id: "google-oauth|10021"
      }
      |> Repo.insert!

    {:ok, _, user} = Search.save_user_search user.id, "test search", %{stuff: "And Things!"}

    assert Enum.all?(user.saved_searches, fn search ->
            attr = search.search_attributes |> Enum.at(0)
            attr.attribute_key == "stuff" && attr.attribute_values == "And Things!"
           end)
  end

  test "delete_search/2 deletes a search for a particular user", %{user: user, search: search} do
    assert %SearchModel{} = Search.delete_search user.id, search.id
  end

end
