defmodule Schema.UserPhoneTest do
  use ExUnit.Case

  alias Schema.Resource.UserPhone
  alias Ecto.Changeset

  test "valid?" do
    changeset = UserPhone.changeset(%UserPhone{}, %{})
    refute changeset.valid?
  end

  test "phone number is valid" do
    changeset = UserPhone.changeset(%UserPhone{}, %{phone_number: "(912)-111-2912"})
    assert changeset.valid?

    changeset = UserPhone.changeset(%UserPhone{}, %{phone_number: "(912) 111 2912"})
    assert changeset.valid?

  end

  test "phone number is NOT valid" do
    changeset = UserPhone.changeset(%UserPhone{}, %{phone_number: "(M12)-111-2912"})
    refute changeset.valid?
  end

  describe "Fixes the phone number format" do

    test "Matches (912)-111-2912 and changes to 19121112912" do
      changeset = UserPhone.changeset(%UserPhone{}, %{phone_number: "(912)-111-2912"})
      assert Changeset.get_change(changeset, :phone_number) == "19121112912"
    end

    test "Matches 9995552211 and changes to 19995552211" do
      changeset = UserPhone.changeset(%UserPhone{}, %{phone_number: "9995552211"})
      assert Changeset.get_change(changeset, :phone_number) == "19995552211"
    end

  end
end
