defmodule InvoicingSystem.Invoicing.Service.Core.Invoices do
  defmacro __using__([]) do
    quote do
      alias InvoicingSystem.Invoicing.Invoice
      alias InvoicingSystem.Invoicing.Service

      def add(%Service{uuid: uuid} = state, :invoice, opts) do
        {[uuid: invoice_uuid], opts} = Keyword.split(opts, [:uuid])
        invoice_number = get_next_invoice_number(state)
        {:ok, invoice} = Invoice.new(opts ++ [number: invoice_number])

        updated_state = Map.update!(state, :invoices, &Map.put_new(&1, invoice_uuid, invoice))
        db_updates = [{:update, uuid, updated_state}]
        {:ok, db_updates, updated_state}
      end

      defp get_next_invoice_number(%{invoices: invoices}) do
        invoices
        |> Enum.map(fn {_uuid, %{number: number}} -> number end)
        |> Enum.max(&>=/2, fn -> 0 end)
        |> :erlang.+(1)
      end
    end
  end
end
