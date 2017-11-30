defmodule Sre.Mixfile do
  use Mix.Project

  def project do
    [app: :sre,
     version: "3.17.7",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    applications = [
      :bamboo,
      :cowboy,
      :feeds,
      :geocalc,
      :geolix,
      :gettext,
      :great_schools,
      :hound,
      :httpoison,
      :leads,
      :listing_search,
      :logger,
      :phoenix_html,
      :phoenix_pubsub,
      :phoenix,
      :rollbax,
      :schema,
      :testimonials,
      :ueberauth_auth0,
      :ueberauth,
      :user
    ]

    # Start New Relic app if we have a license key
    applications = if Application.get_env(:new_relic, :license_key) != nil do
      applications ++ [:new_relic]
    else
      applications
    end

    [
      mod: {Sre, []},
      applications: applications
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bamboo, "~> 0.7"},
      {:browser, "~> 0.2.0"},
      {:cowboy, "~> 1.0"},
      {:decimal, "~> 1.3.0"},
      {:feeds, in_umbrella: true},
      {:geocalc, "~> 0.5.3"},
      {:geolix, "~> 0.10.0"},
      {:gettext, "~> 0.11"},
      {:great_schools, in_umbrella: true},
      {:group, in_umbrella: true},
      {:hound, "~> 1.0"},
      {:httpoison, "~> 0.10.0"},
      {:leads, in_umbrella: true},
      {:listing_search, in_umbrella: true},
      {:new_relic, github: "romul/newrelic.ex", ref: "6f690dca395724f0a24be8c9a54cfec01e482c2a"},
      {:number, "~> 0.5.1"},
      {:phoenix_ecto, "~> 3.0.1"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix, "~> 1.2.0"},
      {:plug_forwarded_peer, "~> 0.0.2"},
      {:rollbax, "~> 0.6"},
      {:testimonials, in_umbrella: true},
      {:ueberauth_auth0, "~> 0.1"},
      {:ueberauth, "~> 0.3"},
      {:user, in_umbrella: true},
      {:tzdata, "~> 0.5.11"}
    ]
  end
end
