defmodule InvoicingSystem.DB.Application do
  use Application

  def start(_type, _args) do
    DeferredConfig.populate(:invoicing_db)

    children = [
      InvoicingSystem.DB.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: InvoicingSystem.DB.Supervisor)
  end
end
