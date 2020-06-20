defmodule InvoincingSystem.API.Invoices.Invoice do
  use InvoicingSystem.DB.Entity

  @impl InvoicingSystem.DB.Entity
  def table(), do: :invoices
end
