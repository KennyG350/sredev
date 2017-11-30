defmodule User.Mixfile do
  use Mix.Project

  def project do
    [app: :user,
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
    [applications: [
      :logger,
      :ecto,
      :postgrex,
      :timex,
      :poison,
      :timex_ecto,
      :httpoison,
      :schema
    ],
    mod: {User, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ecto, "~> 2.1.6"},
      {:phoenix_ecto, "~> 3.0"},
      {:poison, "~> 2.0"},
      {:httpoison, "~> 0.10.0"},
      {:postgrex, "~> 0.13"},
      {:timex_ecto, "~> 3.0"},
      {:timex, "~> 3.0"},
      {:plug, "~> 1.0"},
      {:schema, in_umbrella: true}
    ]
  end
end
