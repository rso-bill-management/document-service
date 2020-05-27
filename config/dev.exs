use Mix.Config

config :joken,
  default_signer: {:system, "INVOICING_JOKEN_SECRET", "some_really_secret_secret"}

config :invoicing_db, InvoicingSystem.DB.Repo,
  database: {:system, "PGDATABASE", "postgres"},
  username: {:system, "PGUSER", "postgres"},
  password: {:system, "PGPASSWORD", "postgres"},
  hostname: {:system, "PGHOST", "postgres"},
  port: {:system, "PGPORT", 5432, {String, :to_integer}}

config :invoicing_storage,
  data_path: {:system, "INVOICING_STORAGE_DATA_PATH", "/tmp"}
