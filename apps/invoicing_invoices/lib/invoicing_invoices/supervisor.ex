defmodule InvoicingSystem.Invoicing.Supervisor do
  use DynamicSupervisor
  alias InvoicingSystem.Invoicing.Service

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def new_user(uuid) do
    DynamicSupervisor.start_child(__MODULE__, {Service, [uuid: uuid]})
  end
end
