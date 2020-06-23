defmodule InvoicingSystem.IAM.MixProject do
  use Mix.Project

  def project() do
    [
      app: :invoicing_iam,
      version: "#{String.trim(File.read!("../../VERSION"))}",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def elixirc_paths(:prod), do: ["lib"]
  def elixirc_paths(:dev), do: ["lib"]
  def elixirc_paths(:test), do: ["lib", "test/test_helpers"]

  def application do
    [
      mod: {InvoicingSystem.IAM.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:argon2_elixir, "~> 2.0"},
      {:joken, "~> 2.1"},
      {:vex, "~> 0.8.0"},

      # UMBRELLA
      {:invoicing_utils, in_umbrella: true},
      {:invoicing_db, in_umbrella: true},

      # TESTS
      {:mock, "~> 0.3.4", only: [:test]}
    ]
  end
end
