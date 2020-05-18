defmodule Invoicing.RPC.MixProject do
  use Mix.Project

  def project() do
    [
      app: :invoicing_api,
      version: "#{String.trim(File.read!("../../VERSION"))}",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      compilers: Mix.compilers(),
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
      mod: {Invoicing.RPC.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.4"},
      {:plug_cowboy, "~> 2.1"},

      # UMBRELLA

      # TESTS
      {:mock, "~> 0.3.4", only: [:test]}
    ]
  end
end
