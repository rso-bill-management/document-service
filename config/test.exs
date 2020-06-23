use Mix.Config

config :logger, level: :error

config :joken,
  default_signer: {:system, "INVOICING_JOKEN_SECRET", "some_really_secret_secret"}


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :invoicing_api, InvoicingSystem.API.Endpoint,
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
