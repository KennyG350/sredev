defmodule Schema.Connection do
  @moduledoc """
  Add support utils for using Schema in other projects
  """
  alias Schema.Repo
  alias Ecto.Adapters.SQL.Sandbox

  def set_repo_test_mode(mode \\ :manual) do
    Sandbox.mode(Repo, mode)
  end

  def check_out_repo_test_connection do
    Sandbox.checkout(Repo)
  end

  def share_db_connection(pid) do
    :ok = check_out_repo_test_connection
    set_repo_test_mode({:shared, pid})
  end
end
