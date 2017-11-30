defmodule User.ManagementTest do
  use ExUnit.Case

  alias Ecto.UUID
  alias User.Management, as: MNG
  alias Schema.{
    Connection,
    Repo,
    Resource.User
  }

  describe "Create or Fetch" do
    setup do
      Connection.share_db_connection self
      {:ok, payload: uberauth_payload}
    end

    test "returns error tuple", %{payload: payload} do
      assert {:error, :no_user_found} = MNG.get_user_by_auth0_profile(payload)
    end

    test "returns {:ok, user}", %{payload: profile} do
      email = "orion.engleton+madmax@gmail.com"
      user = Repo.insert! %User{email: email}
      assert {:ok, user} = MNG.get_user_by_auth0_profile(profile)
    end
  end

  def uberauth_payload do
    %{
      credentials: %{
        expires: true,
        expires_at: 1_481_230_621,
        other: %{"id_token" => "1234-abcdefj"},
        refresh_token: nil, scopes: [""], secret: nil, token: "vPdlFa7keS5E1GKC",
        token_type: "Bearer"}, extra: %{raw_info: %{}},
        info: %{description: nil,
          email: "orion.engleton+madmax@gmail.com", first_name: nil,
            image: "https://s.gravatar.com/xyz.png",
            last_name: nil, location: nil,
            name: "orion.engleton+madmax@gmail.com",
            nickname: "orion.engleton+madmax",
            phone: nil, urls: %{}}, provider: :auth0,
            strategy: __MODULE__,
            uid: "auth0|5848779cb27a678a0500fa38"
    }
  end

  def payload do
    user = %{
      "user_metadata" => %{
        "first_name" => "Julia",
        "last_name" => "Rob"
      },
      "email_verified" => false,
      "name" => "Julia Roberts",
      "email" => "jr.99@gmail.com",
      "user_id" => "#{UUID.generate}#{:rand.uniform(99999)}",
      "picture"  => "-",
      "email_verified" => false
    }
  end

end
