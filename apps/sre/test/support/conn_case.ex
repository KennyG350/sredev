defmodule Sre.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  use Phoenix.ConnTest
  @endpoint Sre.Endpoint

  alias Phoenix.ConnTest

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      import Sre.ConnCase
      import Sre.Router.Helpers
      import Sre.Support.Helpers
      # The default endpoint for testing
      @endpoint Sre.Endpoint
    end
  end

  setup tags do

    {:ok, conn: ConnTest.build_conn()}
  end

  @doc """
  Allows for easy unit-testing of plugs when the `conn` needs to be
  passed through the router for full setup. (For example, when you
  need to test sessions)

  Relies on `Phoenix.ConnTest.bypass_through/3`.

  ## Example

      conn
      |> pipeline([:browser])
      |> YourPlugHere.call([])
  """
  def pipeline(conn, pipelines) do
    conn
    |> bypass_through(Sre.Router, pipelines)
    |> get("/")
  end
end
