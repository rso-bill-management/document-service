defmodule InvoincingSystem.API.Invoices.Invoice do
  use InvoicingSystem.DB.Entity

 @derive {Jason.Encoder, only: [:number, :date_issue, :place_issue, :sales_data, :net_price_sum, :vat_sum, :gross_sum, :payment_type, :payment_days]}
 defstruct [:number, :date_issue, :place_issue, :sales_data, :net_price_sum, :vat_sum, :gross_sum, :payment_type, :payment_days]


 @callback to_renderer_fields(%__MODULE__{}) :: {:ok, Keyword.t()} | {:error, term()}


  def to_renderer_fields(%__MODULE__{type: type} = doc) do
    Map.fetch!(@documents, type)
    |> apply(:to_renderer_fields, [doc])
  end

  def new(opts) do
    invoice = struct(__MODULE__, opts)
    {:ok, invoice}
  end

  @impl InvoicingSystem.DB.Entity
  def table(), do: :invoices
end
