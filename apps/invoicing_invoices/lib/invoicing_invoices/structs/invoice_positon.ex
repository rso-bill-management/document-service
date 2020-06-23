defmodule InvoicingSystem.Invoicing.Structs.InvoicePosition do
  @derive Jason.Encoder
  defstruct [
    :title,
    :count,
    :unit,
    :unitNettoPrice,
    :vat
  ]

  def new(opts) do
    {:ok, struct!(__MODULE__, opts)}
  end
end
