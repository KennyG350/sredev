defmodule Sre.UserManagement.GroupViewTest do
  use ExUnit.Case

  alias Sre.UserManagement.GroupView

  describe "GroupView: " do

    setup do
      groups = [
        %{name: "some other group"},
        %{name: "Favorites"}
      ]

      {:ok, groups: groups}
    end

    test "sort_groups/1 returns the groups sorted with the favorite always first given 2 groups", %{groups: groups} do
      assert [%{name: "Favorites"}, %{name: "some other group"}] = GroupView.sort_groups(groups)
    end

    test "sort_groups/1 returns the groups corretly if favorite is already first", %{groups: groups} do
      groups = Enum.reverse groups
      assert [%{name: "Favorites"} | _]  = GroupView.sort_groups(groups)
    end

    test "sort_groups/1 will move the favorites group to be the first one", %{groups: groups} do
      groups = groups ++ [%{name: "Bob Barker"}, %{name: "Jet Lee"}]
    end
  end
end
