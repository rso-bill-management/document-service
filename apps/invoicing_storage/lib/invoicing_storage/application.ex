defmodule InvoicingSystem.Storage.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.info("Starting application Invoicing System Storage")

    DeferredConfig.populate(:invoicing_storage)
    data_path = Application.fetch_env!(:invoicing_storage, :data_path)

    children = []

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: InvoicingSystem.Storage.Supervisor
    )
  end
end
