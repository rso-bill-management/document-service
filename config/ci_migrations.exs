use Mix.Config

config :invoicing_db, InvoicingSystem.DB.Repo,
  database: "postgres",
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  port: 5432,
