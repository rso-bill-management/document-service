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

    def render(doc) do
        GenServer.call(__MODULE__, {:render, doc})
    end

    def init(opts) do
        Logger.info("Starting renderer.")
    
        templates_path = Keyword.fetch!(opts, :templates_path)
        Logger.info("Template path: #{inspect(templates_path)}")
    
        templates = File.ls!(templates_path)
        
        templates = List.first(templates)
        Logger.info("Found template: #{inspect(template)}")
    
        Logger.info("Loading template")
    
        templates =
          templates
          |> Enum.map(&load_template(templates_path, &1))
          |> Map.new()
    
        Logger.info("Renderer initialised")
        {:ok, struct!(__MODULE__, templates_path: templates_path, templates: templates)}
      end

      # handlers
      def handle_call({:render, %Document{} = doc}, _from, %__MODULE__{templates: templates} = state) do
        Logger.info("Rendering pdf for #{inspect(doc)}")
    
        response =
          with {:ok, template} <- Map.fetch(templates, "pdf_template"),
               {:ok, replacements} <- Invoice.to_renderer_fields(doc),
               {:ok, prepared_doc} <- prepare_document(template, replacements),
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
          shell_params: [
            "--dpi",
            "600"
          ],
          delete_temporary: true
        ]
    
        PdfGenerator.generate_binary(html, opts)
    end

    defp prepare_document(body, replacements) do
        replacements
        |> Enum.reduce(body, &make_replacement/2)
        |> check_all_replaced()
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
