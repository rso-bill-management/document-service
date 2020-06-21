defmodule InvoicingSystem.DB.MixProject do
  use Mix.Project

  def project() do
    [
      app: :invoicing_db,
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
      mod: {InvoicingSystem.DB.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:deferred_config, "~> 0.1.1"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.15.3"}, 
      # TESTS
    ]
  end
end
