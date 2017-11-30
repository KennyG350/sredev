defmodule Schema.Resource.PasswordTokenTest do
  use ExUnit.Case

  alias Schema.{
    Resource.PasswordToken,
    Resource.User
  }
  alias Ecto.{Changeset, DateTime}

  setup do
    changeset = PasswordToken.changeset(%PasswordToken{}, :reset)
    {:ok, changeset: changeset}
  end

  test "validate change", %{changeset: changeset} do
    assert changeset.valid?
  end

  test "valid as User also" do
    changeset = PasswordToken.changeset(%User{}, :reset)
    assert changeset.valid?
  end

  test ".forgot_password_token is binary", %{changeset: changeset} do
    assert is_binary(Changeset.get_change(changeset, :forgot_password_token))
  end

  test ".forgot_password_token_expiration", %{changeset: changeset} do
    date = Changeset.get_change(changeset, :forgot_password_token_expiration)
    {{_y, _m, day}, _} = DateTime.to_erl(date)
    {{_, _, today}, _} = :calendar.universal_time
    assert day == today + 3
  end
end
