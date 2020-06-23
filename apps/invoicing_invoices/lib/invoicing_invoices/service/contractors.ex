defmodule InvoicingSystem.Invoicing.Service.Core.Contractors do
  defmacro __using__(opts) do
    quote do
      alias InvoicingSystem.Invoicing.Service
      alias InvoicingSystem.Invoicing.Structs.Contractor

      def add(%Service{uuid: uuid} = state, :contractor, opts) do
        {:ok, contractor} = Contractor.new(opts)
        updated_state = Map.update!(state, :contractors, &:erlang.++(&1, [contractor]))
        db_updates = [{:update, uuid, updated_state}]
        {:ok, db_updates, updated_state}
      end
    end
  end
end
