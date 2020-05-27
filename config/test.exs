use Mix.Config

config :logger, level: :error

config :joken,
  default_signer: {:system, "INVOICING_JOKEN_SECRET", "some_really_secret_secret"}

config :invoicing,
  # NOTE: `umbrella_root_dir` fixes a common reference path to the root directory
  # of the umbrella project. This is useful because `mix test` and `mix coveralls --umbrella`
  # have different views on the root dir when testing.
  umbrella_root_dir: Path.join(__DIR__, "..")

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :invoicing_rpc, InvoicingSystem.RPC.Endpoint,
  http: [port: 4002],
  server: false

config :invoicing_db, InvoicingSystem.DB.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox

config :invoicing_storage,
  data_path: "/tmp"
