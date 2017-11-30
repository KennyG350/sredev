defmodule Sre.PropertyControllerTest do
  use Sre.ConnCase

  alias Sre.PropertyController

  test "GET /properties/:url", %{conn: conn} do
    assert_raise ListingSearch.BadInputError, fn ->
      PropertyController.details conn, %{"url" => nil}
    end
  end
end
