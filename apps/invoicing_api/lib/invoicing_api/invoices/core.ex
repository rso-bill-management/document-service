defmodule InvoicingSystem.API.Invoices.Core do 
    alias InvoicingSystem.API.Invoices
    alias InvoincingSystem.API.Invoices.Invoice

    def get_invoice(%Invoices{invoices: invoices}, uuid) do
        invoices 
        |> Map.fetch(uuid) 
        |> map_find_result()
    end


    defp map_find_result(:error), do: {:error, :not_found}
    # defp map_find_result({:ok, %Invoice{} = invoice}), do: {:ok, invoice}  
end
