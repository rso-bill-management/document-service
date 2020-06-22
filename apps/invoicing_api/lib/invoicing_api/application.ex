defmodule InvoicingSystem.API.Application do
  use Application
  require Logger

  def start(_, _) do
    children = [
      {InvoicingSystem.API.Renderer, [templates_path: "/Users/tomek/Desktop/rso/document-service/apps/invoicing_api/lib/invoicing_api/views/templates"]},
      { InvoicingSystem.API.Endpoint, []}, 
      { InvoicingSystem.API.Invoices, [] }
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: InvoicingSystem.API.Supervisor)
  end
end
