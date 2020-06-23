defmodule InvoicingSystem.Storage.MixProject do
  use Mix.Project

  def project() do
    [
      app: :invoicing_storage,
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
  def elixirc_paths(_), do: ["lib"]

  def application do
    [
      mod: {InvoicingSystem.Storage.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # UMBRELLA

      # TESTS 
      {:uuid, "~> 1.1", only: [:test]},
      {:briefly, "~> 0.3", only: [:test]}
    ]
  end
end
