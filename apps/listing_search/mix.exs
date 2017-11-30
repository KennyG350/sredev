defmodule ListingSearch.Mixfile do
  @moduledoc """
  Listing search application
  """
  use Mix.Project

  # Project config
  def project do
    [app: :listing_search,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:logger, :postgrex, :ecto, :timex, :timex_ecto],
     mod: {ListingSearch, []}]
  end

  # Dependencies
  defp deps do
    [
      {:ecto, "~> 2.0"},
      {:postgrex, "~> 0.11"},
      {:timex_ecto, "~> 3.0"},
      {:timex, "~> 3.0"}
    ]
  end
end
