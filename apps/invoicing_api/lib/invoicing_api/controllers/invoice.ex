defmodule InvoicingSystem.API.InvoiceController do
  use InvoicingSystem.API, :controller

  alias InvoicingSystem.Invoicing.Service
  alias InvoicingSystem.API.Renderer

  require Logger

  def index(%{assigns: %{user: %{uuid: user_uuid}}} = conn, _) do 
    Logger.info("User #{user_uuid} | Getting invoices")
    case Service.invoices(user_uuid) do
      {:ok, invoices} ->
        {:ok, %{invoices: invoices}}

      error ->
        {:internal_server_error, %{error: error}}
    end
    |> json_resp(conn)
  end

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

  def new_contractor(
        %{assigns: %{user: %{uuid: user_uuid}}} = conn,
        %{
          "name" => name,
          "tin" => tin,
          "street" => street,
          "town" => town,
          "postalCode" => postalCode
        } = contractor
      ) do
    Logger.info("User #{user_uuid} | Adding new contractor: #{contractor}")

    opts = [
      name: name,
      tin: tin,
      town: town,
      street: street,
      postalCode: postalCode
    ]

    case Service.add_contractor(user_uuid, opts) do
      :ok -> {:ok, %{status: :ok}}
      error -> {:internal_server_error, error}
    end
    |> json_resp(conn)
  end

  def predefined_items(%{assigns: %{user: %{uuid: user_uuid}}} = conn, _) do
    Logger.info("User #{user_uuid} | Getting predefined items")

    case Service.predefined_items(user_uuid) do
      {:ok, items} ->
        {:ok, %{predefined_items: items}}

      error ->
        {:internal_server_error, %{error: error}}
    end
    |> json_resp(conn)
  end

  def new_predefined_item(
        %{assigns: %{user: %{uuid: user_uuid}}} = conn,
        %{
          "title" => title,
          "vat" => vat,
          "unit" => unit,
          "unitNettoPrice" => unitNettoPrice,
          "count" => count
        } = item
      )
      when is_number(count) and is_integer(vat) and is_number(unitNettoPrice) do
    Logger.info("User #{user_uuid} | Adding new predefined item: #{item}")

    opts = [
      title: title,
      vat: vat,
      unit: unit,
      unitNettoPrice: unitNettoPrice,
      count: count
    ]

    case Service.add_predefined_item(user_uuid, opts) do
      :ok -> {:ok, %{status: :ok}}
      error -> {:internal_server_error, error}
    end
    |> json_resp(conn)
  end

  def pdf(conn, %{"uuid" => uuid}) do
    with {:ok, invoice} <- Invoices.get_invoice(uuid),
         {:ok, file_contents} <- Renderer.render(invoice) do
      Logger.info("Downloading pdf file from backend")

      send_download(conn, {:binary, file_contents},
        filename: "invoice_#{invoice.number}_#{invoice.date_issue}.pdf"
      )
    else
      _error ->
        json_resp({:not_found, %{error: :not_found}}, conn)
    end
  end
end
