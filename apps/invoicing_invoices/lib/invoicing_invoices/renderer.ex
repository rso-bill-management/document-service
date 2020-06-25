defmodule InvoicingSystem.Invoicing.Renderer do
  @moduledoc """
  A GenServer that takes responsibility for rendering a pdf of invoice.
  """
  use GenServer

  require Logger

  defstruct [:templates_path, :templates]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def render(invoice, user, seller) do
    GenServer.call(__MODULE__, {:render, invoice, user, seller})
  end

  def init(opts) do
    Logger.info("Starting renderer.")

    templates_path = Keyword.fetch!(opts, :templates_path)
    Logger.info("Template path: #{inspect(templates_path)}")

    templates = File.ls!(templates_path)

    Logger.info("Found template: #{inspect(templates)}")

    Logger.info("Loading template")

    templates =
      templates
      |> Enum.map(&load_template(templates_path, &1))
      |> Map.new()

    Logger.info("Renderer initialised")
    {:ok, struct!(__MODULE__, templates_path: templates_path, templates: templates)}
  end

  # handlers
  def handle_call(
        {:render, invoice, user, seller},
        _from,
        %__MODULE__{templates: templates} = state
      ) do
    Logger.info("Rendering pdf for #{inspect(invoice)}")

    response =
      with {:ok, template} <- Map.fetch(templates, :pdf_template),
           replacements <- invoice_to_replacements(invoice, user, seller),
           {:ok, prepared_doc} <-
             prepare_document(template, replacements),
           {:ok, pdf} <- render_pdf(prepared_doc) do
        Logger.info("Successfully rendered a pdf")
        {:ok, pdf}
      end

    {:reply, response, state}
  end

  #  Private
  defp render_pdf(html) do
    opts = [
      page_size: "A4",
      delete_temporary: true,
      shell_params: [
        "--dpi",
        "600"
      ]
    ]

    PdfGenerator.generate_binary(html, opts)
  end

  defp prepare_document(body, replacements) do
    replacements
    |> Enum.reduce(body, &make_replacement/2)
    |> check_all_replaced()
  end

  defp make_replacement(_, {:error, _} = error), do: error

  defp make_replacement({placeholder, value}, body) do
    updated_body = String.replace(body, "{{#{placeholder}}}", "#{value}")

    if updated_body == body do
      {:error, {:not_replaced, placeholder}}
    else
      updated_body
    end
  end

  defp check_all_replaced({:error, _} = error), do: error

  defp check_all_replaced(body) do
    if String.match?(body, ~r/{{[[:lower:]][[:lower:][:digit:]-_]*}}/u) do
      {:error, :not_all_placeholders_replaced}
    else
      {:ok, body}
    end
  end

  defp invoice_to_replacements(
         %{
           number: number,
           saleDate: sale_date,
           dateIssue: issue_date,
           paymentType: payment,
           paymentDays: payment_date,
           contractor: contractor,
           positions: positions,
           netPriceSum: net_price,
           vatSum: vat_sum,
           grossSum: gross_sum
         },
         user,
         seller
       ) do
    [
      number: number,
      issue_date: issue_date,
      sale_date: sale_date,
      payment: payment,
      payment_date: payment_date,
      net_price: net_price,
      vat_sum: vat_sum,
      gross_sum: gross_sum,
      user_name: "#{user.name} #{user.surname}",
      positions: map_positions(positions)
    ]
    |> Kernel.++(contractor_to_replacements(contractor))
    |> Kernel.++(seller_to_replacements(seller))
  end

  defp contractor_to_replacements(%{
         name: name,
         tin: tin,
         town: town,
         street: street,
         postalCode: postalCode
       }) do
    [
      contractor_name: name,
      contractor_street: street,
      contractor_nip: tin,
      contractor_city: "#{postalCode} #{town}"
    ]
  end

  defp seller_to_replacements(%{
         tin: tin,
         companyName: companyName,
         town: town,
         postalCode: postalCode,
         accountNumber: accountNumber,
         street: street
       }) do
    [
      seller_name: companyName,
      seller_street: street,
      seller_city: "#{postalCode} #{town}",
      seller_nip: tin,
      seller_account: accountNumber
    ]
  end

  defp map_positions(positions) do
    positions
    |> Enum.with_index(1)
    |> Enum.map(&map_position/1)
    |> List.foldr("", &Kernel.<>/2)
  end

  defp map_position({position, index}) do
    gross_netto = (position.unitNettoPrice * position.count) |> Float.round(2)

    """
    <tr>
         <td>#{index}.</td>
         <td>#{position.title}</td>
         <td>#{position.count}</td>
         <td>#{position.unit}</td>
         <td>#{position.unitNettoPrice}</td>
         <td>#{gross_netto}</td>
         <td>#{position.vat}</td>
      </tr>
    """
  end

  defp load_template(templates_path, template) do
    file =
      Path.join(templates_path, template)
      |> File.read!()

    template =
      template
      |> String.replace_suffix(".html", "")
      |> String.to_atom()

    {template, file}
  end
end
