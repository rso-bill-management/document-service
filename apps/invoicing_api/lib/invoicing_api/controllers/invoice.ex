defmodule InvoicingSystem.API.InvoiceController do
  use InvoicingSystem.API, :controller

  alias InvoicingSystem.Invoicing.Service
  alias InvoicingSystem.API.Renderer

  require Logger

  def index(%{assigns: %{user: %{uuid: user_uuid}}} = conn, _) do
    Logger.info("User #{user_uuid} | Getting invoices")

    case Service.invoices(user_uuid) do
      {:ok, invoices} ->
        invoices
        |> Enum.map(fn
          {k, v} -> Map.from_struct(v) |> Map.put_new(:uuid, k)
        end)

        {:ok, invoices}

      error ->
        {:internal_server_error, %{error: error}}
    end
    |> json_resp(conn)
  end

  def seller(
        %{assigns: %{user: %{uuid: user_uuid}}} = conn,
        _
      ) do
    Logger.info("User #{user_uuid} | Getting seller")

    case Service.seller(user_uuid) do
      {:ok, seller} -> {:ok, seller}
      error -> {:internal_server_error, error}
    end
    |> json_resp(conn)
  end

  def set_seller(
        %{assigns: %{user: %{uuid: user_uuid}}} = conn,
        %{
          "tin" => tin,
          "companyName" => companyName,
          "accountNumber" => accountNumber,
          "street" => street,
          "town" => town,
          "postalCode" => postalCode
        } = seller
      ) do
    Logger.info("User #{user_uuid} | Setting seller")

    opts = [
      tin: tin,
      companyName: companyName,
      town: town,
      postalCode: postalCode,
      accountNumber: accountNumber,
      street: street
    ]

    case Service.set_seller(user_uuid, opts) do
      :ok -> {:ok, %{status: :ok}}
      error -> {:internal_server_error, error}
    end
    |> json_resp(conn)
  end

  def contractors(%{assigns: %{user: %{uuid: user_uuid}}} = conn, _) do
    Logger.info("User #{user_uuid} | Getting contractors")

    case Service.contractors(user_uuid) do
      {:ok, contractors} ->
        {:ok, contractors}

      error ->
        {:internal_server_error, %{error: error}}
    end
    |> json_resp(conn)
  end

  def new_invoice(
        %{assigns: %{user: %{uuid: user_uuid}}} = conn,
        %{
          "dateIssue" => dateIssue,
          "placeIssue" => placeIssue,
          "saleDate" => saleDate,
          "contractor" => contractor,
          "positions" => positions,
          "netPriceSum" => netPriceSum,
          "vatSum" => vatSum,
          "grossSum" => grossSum,
          "paymentType" => paymentType,
          "paymentDays" => paymentDays
        } = invoice
      )
      when is_number(netPriceSum) and is_number(vatSum) and is_number(grossSum) and
             is_number(paymentDays) do
    Logger.info("User #{user_uuid} | Adding new invoice: #{inspect(invoice)}")

    contractor = to_keyword(contractor)
    positions = Enum.map(positions, &to_keyword/1)

    opts = [
      dateIssue: dateIssue,
      placeIssue: placeIssue,
      saleDate: saleDate,
      contractor: contractor,
      positions: positions,
      netPriceSum: netPriceSum,
      vatSum: vatSum,
      grossSum: grossSum,
      paymentType: paymentType,
      paymentDays: paymentDays
    ]

    case Service.add_invoice(user_uuid, opts) do
      :ok -> {:ok, %{status: :ok}}
      error -> {:internal_server_error, error}
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
    Logger.info("User #{user_uuid} | Adding new contractor: #{inspect(contractor)}")

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
        {:ok, items}

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
    Logger.info("User #{user_uuid} | Adding new predefined item: #{inspect(item)}")

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

  defp to_keyword(%{
         "title" => title,
         "vat" => vat,
         "unit" => unit,
         "unitNettoPrice" => unitNettoPrice,
         "count" => count
       })
       when is_number(count) and is_integer(vat) and is_number(unitNettoPrice) do
    [
      title: title,
      vat: vat,
      unit: unit,
      unitNettoPrice: unitNettoPrice,
      count: count
    ]
  end

  defp to_keyword(%{
         "name" => name,
         "tin" => tin,
         "street" => street,
         "town" => town,
         "postalCode" => postalCode
       }) do
    [
      name: name,
      tin: tin,
      town: town,
      street: street,
      postalCode: postalCode
    ]
  end
end
