defmodule InvoicingSystem.Invoices.MixProject do
  use Mix.Project

  def project() do
    [
      app: :invoicing_invoices,
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
      mod: {InvoicingSystem.Invoicing.Application, []},
      extra_applications: [:logger, :pdf_generator]
    ]
  end

  defp deps do
    [
      {:deferred_config, "~> 0.1.1"},
      {:uuid, "~> 1.1"},
      {:pdf_generator, ">=0.4.0"},

      # UMBRELLA
      {:invoicing_utils, in_umbrella: true},
      {:invoicing_db, in_umbrella: true},
      {:invoicing_storage, in_umbrella: true}
      # TESTS 
    ]
  end
end
