defmodule InvoicingSystem.Invoicing.Service.Core do
  use InvoicingSystem.Invoicing.Service.Core.Contractors
  use InvoicingSystem.Invoicing.Service.Core.Invoices
  use InvoicingSystem.Invoicing.Service.Core.PredefinedItems

  alias InvoicingSystem.Invoicing.Service

  def get(%Service{} = state, entity) when is_map_key(state, entity) do
    Map.fetch(state, entity)
  end
end
