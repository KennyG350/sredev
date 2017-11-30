defmodule Schema.UserProfileTest do
  use ExUnit.Case

  alias Schema.Resource.UserProfile
  alias Ecto.Changeset

  test "valid?" do
    changeset = UserProfile.changeset(%UserProfile{}, %{})
    refute changeset.valid?
  end
end
