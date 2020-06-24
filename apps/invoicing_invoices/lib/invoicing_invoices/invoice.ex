defmodule InvoicingSystem.Invoicing.Invoice do
  @derive Jason.Encoder
  defstruct [
    :number,
    :dateIssue,
    :placeIssue,
    :salesData,
    :netPriceSum,
    :vatSum,
    :grossSum,
    :paymentType,
    :paymentDays
  ]

  def new(opts) do
    {:ok, struct!(__MODULE__, opts)}
  end
end
