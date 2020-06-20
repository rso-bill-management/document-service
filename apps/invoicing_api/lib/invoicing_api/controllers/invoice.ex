defmodule InvoicingSystem.API.InvoiceController do
    # use InvoicingSystem.API, :controller
    # use InvoicingSystem.IAM.Authenticator
 
    alias InvoicingSystem.API.Invoices
    require Logger
    use Phoenix.Controller, namespace: InvoicingSystem.API # temp
  
    def show(conn, %{"uuid" => uuid}) do
        with {:ok, invoice} <- Invoices.get_invoice(uuid) do
             json_resp({:ok, %{witam: invoice}}, conn)
        else
        error ->
            Logger.warn("Could not download pdf: #{inspect(error)}")
            json_resp({:not_found, %{error: :not_found}}, conn)
        end
    end

    # temp
    def json_resp({status, body}, conn) do
        conn |> put_status(status) |> json(body)
    end
end
  