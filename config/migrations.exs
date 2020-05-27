# Environment used in ecto db migrations
use Mix.Config

config :invoicing_db, InvoicingSystem.DB.Repo,
  database: "${PGDATABASE}",
  username: "${PGUSER}",
  password: "${PGPASSWORD}",
  hostname: "${PGHOST}",
  port: ${PGPORT}
