defmodule InvoicingSystem.API.Renderer do
  @moduledoc """
  A GenServer that takes responsibility for rendering a pdf of invoice.
  """
  use GenServer

  require Logger

  alias InvoincingSystem.API.Invoices.Invoice

  defstruct [:templates_path, :templates]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def render(invoice) do
    GenServer.call(__MODULE__, {:render, invoice})
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
  def handle_call({:render, invoice}, _from, %__MODULE__{templates: templates} = state) do
    Logger.info("Rendering pdf for #{inspect(invoice)}")

    response =
      with {:ok, template} <- Map.fetch(templates, :pdf_template),
           {:ok, prepared_doc} <-
             prepare_document(template, Enum.map(invoice, fn {k, v} -> {k, v} end)),
           {:ok, pdf} <- render_pdf(prepared_doc) do
        Logger.info("Successfully rendered a pdf #{inspect(pdf)}")
        {:ok, pdf}
      end

    {:reply, response, state}
  end

  #  Private
  defp render_pdf(html) do
    opts = [
      page_size: "A4",
      # delete_temporary: true,
      shell_params: [
        "--dpi",
        "600"
      ]
    ]

    PdfGenerator.generate(html, opts) |> IO.inspect()
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
