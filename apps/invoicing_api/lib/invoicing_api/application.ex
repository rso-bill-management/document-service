defmodule InvoicingSystem.API.Application do
  use Application
  require Logger

  def start(_, _) do
    children = [
      {InvoicingSystem.API.Renderer, []},
      { InvoicingSystem.API.Endpoint, []}, 
      { InvoicingSystem.API.Invoices, [] }
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: InvoicingSystem.API.Supervisor)
  end
end
