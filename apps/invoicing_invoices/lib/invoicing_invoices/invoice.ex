defmodule InvoicingSystem.Invoicing.Invoice do
  alias InvoicingSystem.Invoicing.Structs

  @derive Jason.Encoder
  defstruct [
    :number,
    :dateIssue,
    :placeIssue,
    :saleDate,
    :contractor,
    :positions,
    :netPriceSum,
    :vatSum,
    :grossSum,
    :paymentType,
    :paymentDays
  ]

  def new(opts) do
    contractor = Keyword.fetch!(opts, :contractor) |> Structs.Contractor.new()

    positions =
      Keyword.fetch!(opts, :positions)
      |> Enum.map(fn opts ->
        {:ok, positon} = Structs.InvoicePosition.new(opts)
        positon
      end)

    updated_opts = Keyword.merge(opts, contractor: contractor, positions: positions)

    {:ok, struct!(__MODULE__, updated_opts)}
  end
end
