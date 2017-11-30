defmodule Sre.RequireLoginTest do
  use Sre.ConnCase

  alias Sre.RequireLogin
  alias Schema.{Repo, Resource.User}

  setup %{conn: conn} do
    conn = %{conn | host: "localhost"}
    {:ok, conn: conn}
  end

  test "redirects if no current_user assign", %{conn: conn} do
    conn =
      conn
      |> pipeline([:browser])
      |> RequireLogin.call([])

    assert conn.halted
    assert get_flash(conn, :error)
  end

  test "does nothing if there is a current_person assign", %{conn: conn} do
    user = Repo.insert! %User{first_name: "Jane", last_name: "Doe", email: "jane.doe@sre.com"}
    conn =
      conn
      |> pipeline([:browser])
      |> assign(:current_user, user)
      |> RequireLogin.call([])

    refute conn.halted
    refute get_flash(conn, :error)
  end

end
