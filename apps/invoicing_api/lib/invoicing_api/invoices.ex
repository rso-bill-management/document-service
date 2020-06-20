defmodule InvoicingSystem.API.Invoices do 
    @moduledoc """
    A GenServer that takes responsibility for managment of invoices.
    """
    use GenServer

    require Logger 
    
    alias InvoicingSystem.API.Invoices.Core
    alias InvoincingSystem.API.Invoices.Invoice
    alias InvoicingSystem.DB
    alias UUID

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
            # |> (&Map.merge(invoices, &1)).()

        {:noreply, %{state | invoices: updated_invoices}}
    end

    def get_invoice(uuid) do 
        GenServer.call(__MODULE__, {:get, uuid})
    end

    # handlers 
    def handle_call({:get, uuid}, _from, state) do 
        {:reply, Core.get_invoice(state, uuid), state}
    end
end