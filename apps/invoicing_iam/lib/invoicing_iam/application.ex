defmodule InvoicingSystem.IAM.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.info("Starting #{__MODULE__}")

    DeferredConfig.populate(:invoicing_iam)
    DeferredConfig.populate(:joken)

    children = [
      {InvoicingSystem.IAM.Users, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: InvoicingSystem.IAM.Supervisor)
  end
end
