defmodule InvoicingSystem.DB.Repo do
  use Ecto.Repo,
    otp_app: :invoicing_db,
    adapter: Ecto.Adapters.Postgres
end
