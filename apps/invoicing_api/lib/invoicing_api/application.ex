defmodule Invoicing.API.Application do
  use Application
  require Logger

  def start(_, _) do
    children = [Invoicing.API.Endpoint]

    Supervisor.start_link(children, strategy: :one_for_one, name: Invoicing.API.Supervisor)
  end
end
