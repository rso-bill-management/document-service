defmodule InvoicingSystem.API.Application do
  use Application
  require Logger

  def start(_, _) do
    templates_path = Application.fetch_env!(:invoicing_invoices, :templates_path)

    children = [
      {InvoicingSystem.API.Renderer, [templates_path: templates_path]},
      {InvoicingSystem.API.Endpoint, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: InvoicingSystem.API.Supervisor)
  end
end
