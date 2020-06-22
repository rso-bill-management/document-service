defmodule InvoicingSystem.API.InvoiceController do
    use InvoicingSystem.API, :controller

    alias InvoicingSystem.API.Invoices

    # TODO: pdf generation
    def show(conn, %{"uuid" => uuid}) do
        with {:ok, invoice} <- Invoices.get_invoice(uuid),
             {:ok, file_contents} <- do
            send_download(conn, {:binary, file_contents},
                filename: "#{String.replace(name, " ", "_")}.pdf"
            )
            #  json_resp({:ok, %{invoice: invoice}}, conn)
        else
        error ->
            json_resp({:not_found, %{error: :not_found}}, conn)
        end
    end
end
  