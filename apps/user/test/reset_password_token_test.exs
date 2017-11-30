defmodule User.ResetPasswordTokenTest do

  use ExUnit.Case

  alias Ecto.UUID

  alias User.PasswordToken, as: Token

  alias Schema.{
    Connection,
    Resource.User,
    Repo
  }

  setup do
    Connection.share_db_connection self

    user = Repo.insert!(user_details)
    {:ok, user: user}
  end

  test "set password token", %{user: user} do
    assert is_nil user.forgot_password_token
    user_with_token = Token.set_reset_password_token(user)
    refute is_nil user_with_token.forgot_password_token
    assert user_with_token.id == user.id
  end

  test ".fetch_by_email", %{user: user} do
    assert user.id == Token.fetch_by_email(user.email).id
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
