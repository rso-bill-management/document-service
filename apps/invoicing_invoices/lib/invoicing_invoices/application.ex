defmodule InvoicingSystem.Invoicing.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.info("Starting application Invoicing System Invoices")

    DeferredConfig.populate(:invoicing_invoices)
    renderer_templates_path = Application.fetch_env!(:invoicing_invoices, :templates_path)

    children = []

    opts = [strategy: :one_for_one, name: InvoicingSystem.Invoicing.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
