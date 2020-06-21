defmodule InvoicingSystem.DB.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:data, :binary, null: false)
    end 
  end
end
