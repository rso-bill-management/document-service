defmodule InvoicingSystem.API.InvoiceController do
  use InvoicingSystem.API, :controller

  alias InvoicingSystem.Invoicing.Service
  alias InvoicingSystem.API.Renderer

  require Logger

  def contractors(%{assigns: %{user: %{uuid: user_uuid}}} = conn, _) do
    Logger.info("User #{user_uuid} | Getting contractors")

    case Service.contractors(user_uuid) do
      {:ok, contractors} ->
        {:ok, %{contractors: contractors}}

      error ->
        {:internal_server_error, %{error: error}}
    end
    |> json_resp(conn)
  end

  def pdf(conn, %{"uuid" => uuid}) do
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
