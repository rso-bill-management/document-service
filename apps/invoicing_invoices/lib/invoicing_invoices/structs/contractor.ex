defmodule InvoicingSystem.Invoicing.Structs.Contractor do
  defstruct [
    :name,
    :tin,
    :town,
    :street,
    :postalCode
  ]

  def new(opts) do
    {:ok, struct!(__MODULE__, opts)}
  end
end
