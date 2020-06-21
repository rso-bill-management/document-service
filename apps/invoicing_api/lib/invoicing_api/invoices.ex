defmodule InvoicingSystem.API.Invoices do 
    @moduledoc """
    A GenServer that takes responsibility for managment of invoices.
    """
    use GenServer

    alias InvoicingSystem.API.Invoices.Core
    alias InvoincingSystem.API.Invoices.Invoice
    alias InvoicingSystem.DB
    alias UUID

    require Logger 

    @invoice_uuid "00000000-0000-0000-0000-000000006969"

    defstruct invoices: %{}
    
    def start_link(invoices \\ []) do
        GenServer.start_link(__MODULE__, invoices, name: __MODULE__)
    end
    
    def init(invoices) do
        Logger.info("Starting #{inspect(__MODULE__)}")
        {:ok, struct!(__MODULE__, invoices: Map.new(invoices)), {:continue, :setup}}
    end

    def handle_continue(:setup, %__MODULE__{invoices: invoices} = state) do
        Logger.info("Loading invoices from DB")

        updated_invoices = 
            DB.get(:invoices)
            |> Map.new()
            |> (&Map.merge(invoices, &1)).()
            |> inject_mock_invoice()

        {:noreply, %{state | invoices: updated_invoices}}
    end

    def get_invoice(uuid) do 
        GenServer.call(__MODULE__, {:get, uuid})
    end

    # handlers 
    def handle_call({:get, uuid}, _from, state) do 
        {:reply, Core.get_invoice(state, uuid), state}
    end

    defp inject_mock_invoice(init_invoices) do
      if Map.has_key?(init_invoices, @invoice_uuid) do
        init_invoices
      else
        Logger.warn("Injecting mock invoice")
        
        {:ok, mock_invoice} = 
          Invoice.new(number: "123", date_issue: "~D[2020-06-21]", place_issue: "place", sales_data: "~D[2020-06-21]", net_price_sum: "6969", vat_sum: "123", gross_sum: "123", payment_type: "transfer", payment_days: 3.14)
    
        :ok = DB.execute([{:add, @invoice_uuid, mock_invoice}])
    
        Map.put_new(init_invoices, @invoice_uuid, mock_invoice)
      end
    end
end