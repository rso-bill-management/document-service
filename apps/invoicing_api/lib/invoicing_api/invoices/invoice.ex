defmodule InvoincingSystem.API.Invoices.Invoice do
  use InvoicingSystem.DB.Entity
  use MakeEnumerable

 @derive {Jason.Encoder, only: [:number, :date_issue, :place_issue, :sales_data, :net_price_sum, :vat_sum, :gross_sum, :payment_type, :payment_days]}
 defstruct [:number, :date_issue, :place_issue, :sales_data, :net_price_sum, :vat_sum, :gross_sum, :payment_type, :payment_days]

  def new(opts) do
    invoice = struct(__MODULE__, opts)
    {:ok, invoice}
  end

  @impl InvoicingSystem.DB.Entity
  def table(), do: :invoices
end
