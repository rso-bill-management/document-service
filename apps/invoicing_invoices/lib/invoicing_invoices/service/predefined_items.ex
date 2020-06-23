defmodule InvoicingSystem.Invoicing.Service.Core.PredefinedItems do
  defmacro __using__([]) do
    quote do
      alias InvoicingSystem.Invoicing.Service
      alias InvoicingSystem.Invoicing.Structs.InvoicePosition

      def add(%Service{uuid: uuid} = state, :item, opts) do
        {:ok, item} = InvoicePosition.new(opts)
        updated_state = Map.update!(state, :items, &:erlang.++(&1, [item]))
        db_updates = [{:update, uuid, updated_state}]
        {:ok, db_updates, updated_state}
      end
    end
  end
end
