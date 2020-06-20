defmodule InvoicingSystem.DB.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:data, :binary, null: false)
      # add :uuid, :uuid, primary_key: true
      # add :number, :string
      # add :date_issue, :date
      # add :place_issue, :string
      # add :sales_data, :date
      # add :net_price_sum, :float
      # add :vat_sum, :float
      # add :gross_sum, :float
      # add :payment_type, PaymentTypeEnum.type()
      # add :payment_days, :float
  
      # timestamps()
    end 
  end
end
