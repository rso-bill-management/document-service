defmodule InvoicingSystem.Invoicing.Invoice do
  @derive Jason.Encoder
  defstruct [
    :number,
    :date_issue,
    :place_issue,
    :sales_data,
    :net_price_sum,
    :vat_sum,
    :gross_sum,
    :payment_type,
    :payment_days
  ]

  def new(opts) do
    {:ok, struct!(__MODULE__, opts)}
  end
end
