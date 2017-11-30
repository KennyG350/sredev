defmodule ListingSearch do
  @moduledoc """
  Conveniences for fetching property data from the database
  """
  use Application

  # Start application
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(ListingSearch.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: ListingSearch.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
