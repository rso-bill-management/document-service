defmodule InvoicingSystem.API.InvoiceController do
    use InvoicingSystem.API, :controller

    alias InvoicingSystem.API.Invoices
    alias InvoicingSystem.API.Renderer

    require Logger

    def show(conn, %{"uuid" => uuid}) do
        with {:ok, invoice} <- Invoices.get_invoice(uuid),
             {:ok, file_contents} <- Renderer.render(invoice) do
            Logger.info("Downloading pdf file from backend")
            send_download(conn, {:binary, file_contents},
                filename: "#{invoice.number}_#{invoice.date_issue}.pdf"
            )
        else
        error ->
            json_resp({:not_found, %{error: :not_found}}, conn)
        end
    end
end
  