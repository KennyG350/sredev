defmodule Schema.Mixfile do
  use Mix.Project

  def project do
    [app: :schema,
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
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ecto, :postgrex, :timex],
     mod: {Schema, apps(Mix.env)}]
  end

  def apps(:test) do
    [:poison]
  end

  def apps(_) do
    []
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.1.6"},
      {:postgrex, "~> 0.13"},
      {:timex_ecto, "~> 3.0"},
      {:timex, "~> 3.0"},
      {:poison, "~> 2.2", only: [:test]}
    ]
  end
end
