defmodule InvoicingSystem.Utils.MixProject do
  use Mix.Project

  def project() do
    [
      app: :invoicing_utils,
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

  defp deps do
    [
      {:jason, "~> 1.2.0"},
      {:timex, "~> 3.0"}
    ]
  end
end
