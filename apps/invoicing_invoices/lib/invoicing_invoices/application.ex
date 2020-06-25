defmodule InvoicingSystem.Invoicing.Application do
  @moduledoc false

  use Application

  alias InvoicingSystem.IAM
  require Logger

  def start(_type, _args) do
    Logger.info("Starting application Invoicing System Invoices")

    DeferredConfig.populate(:invoicing_invoices)
    templates_path = Application.fetch_env!(:invoicing_invoices, :templates_path)

    children = [
      {InvoicingSystem.Invoicing.Renderer, [templates_path: templates_path]},
      {InvoicingSystem.Invoicing.Supervisor, []}
    ]

    opts = [strategy: :one_for_one, name: InvoicingSystem.Invoicing.AppSupervisor]
    result = Supervisor.start_link(children, opts)

    :ok = start_user_services()

    result
  end

  defp start_user_services() do
    users = IAM.Users.get() |> Map.keys()

    Enum.each(users, fn uuid ->
      {:ok, _pid} = InvoicingSystem.Invoicing.Supervisor.new_user(uuid)
    end)
  end
end
