defmodule InvoicingSystem.Invoicing.Service.Core do

  alias InvoicingSystem.Invoicing.Invoice
  alias InvoicingSystem.Invoicing.Service
  alias InvoicingSystem.Invoicing.Structs.Contractor

  def add_contractor(%Service{uuid: uuid} = state, %Contractor{} = contractor) do
    updated_state = Map.update!(state, :contractors, &:erlang.++(&1, [contractor]))
    db_updates = [{:update, uuid, updated_state}] 
    {:ok, db_updates, updated_state}
  end

  def add_invoice(%Service{uuid: uuid} = state, %Invoice{} = invoice) do

    invoice_number = get_next_invoice_number(state) 
    invoice = %{invoice | number: invoice_number}

    updated_state = Map.update!(state, :invoices, &:erlang.++(&1, [invoice]))
    db_updates = [{:update, uuid, updated_state}] 
    {:ok, db_updates, updated_state}
  end


  defp get_next_invoice_number(%{invoices: invoices}) do 
    invoices
    |> Enum.map(fn %{number: number} -> number end)
    |> Enum.max(&>=/2, fn -> 1 end)
  end
end
