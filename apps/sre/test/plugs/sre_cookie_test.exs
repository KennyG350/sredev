defmodule Sre.SreCookieTest do
  use Sre.ConnCase

  alias Sre.SreCookie
  alias Schema.Resource.User

  setup %{conn: conn} do
    conn = %{conn | host: "localhost"}
    {:ok, conn: conn}
  end

  test "no session", %{conn: conn} do
    conn =
      conn
      |> pipeline([:browser])
      |> SreCookie.call([])

    user = conn.assigns.guest_user
    assert %User{} = user
  end

end
