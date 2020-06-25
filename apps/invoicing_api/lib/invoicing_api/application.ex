defmodule InvoicingSystem.API.Application do
  use Application
  require Logger

  def start(_, _) do

    children = [
      {InvoicingSystem.API.Endpoint, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: InvoicingSystem.API.Supervisor)
  end
end
