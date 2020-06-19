defmodule InvoicingSystem.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "#{String.trim(File.read!("VERSION"))}",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_paths: test_paths(),
      releases: releases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:deferred_config, "~> 0.1.1"},
      {:uuid, "~> 1.1"},

      ### TESTS
      {
        :ex_unit_fixtures,
        git: "https://github.com/omisego/ex_unit_fixtures.git",
        branch: "feature/require_files_not_load",
        only: [:test]
      }
    ]
  end

  defp releases() do
    [
      phoenix: [
        applications: [invoicing_api: :permanent]
      ],
      iam: [
        applications: [invoicing_iam: :permanent]
      ]
    ]
  end

  defp test_paths() do
    "apps/*/test" |> Path.wildcard() |> Enum.sort()
  end

  defp aliases() do
    [
      test: ["test --color --no-start"],
      "ecto.reset": ["ecto.drop", "ecto.migrate"]
    ]
  end
end
