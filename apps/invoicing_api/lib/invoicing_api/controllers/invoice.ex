defmodule InvoicingSystem.API.InvoiceController do
    use InvoicingSystem.API, :controller
     
    alias InvoicingSystem.API.Invoices

    # TODO: pdf generation
    def show(conn, %{"uuid" => uuid}) do
        with {:ok, invoice} <- Invoices.get_invoice(uuid) do
             json_resp({:ok, %{invoice: invoice}}, conn)
        else
        error ->
            json_resp({:not_found, %{error: :not_found}}, conn)
        end
    end
end
  