defmodule User.UserRegistrationTest do

  use ExUnit.Case

  alias Ecto.{UUID, Changeset}

  alias Schema.{
    Connection,
    Resource.User,
    Repo
  }

  setup do
    Connection.share_db_connection self
    :ok
  end

  test "registration token set" do
    changeset = User.registration_changeset(user_details)
    assert Changeset.get_field(changeset, :verify_email_token)
    refute is_nil(Changeset.get_field(changeset, :verify_email_token))

    assert Changeset.get_field(changeset, :verify_email_expiration)
    refute is_nil(Changeset.get_field(changeset, :verify_email_expiration))

    assert changeset.valid?
  end

  def user_details do
    %User{
      :first_name => "Jane",
      :last_name => "Doe",
      :picture => "http://string/to/photo",
      :email => "#{UUID.generate}@sre.com",
      :email_verified => true,
      :auth_0_id => UUID.generate
     }
  end

end
