defmodule InvoicingSystem.Invoicing.Service do
  use GenServer
  require Logger

  use InvoicingSystem.DB.Entity
  alias InvoicingSystem.DB
  alias InvoicingSystem.Invoicing.Structs
  alias InvoicingSystem.Invoicing.Invoice

  defstruct [
    :uuid,
    contractors: [],
    invoices: [],
    seller: %{}
  ]

  def start_link(opts) do
    uuid = Keyword.fetch!(opts, :uuid)
    GenServer.start_link(__MODULE__, opts, name: String.to_atom(uuid))
  end

  def contractors(uuid) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:contractors, :get})

    response
  end

  def add_contractor(uuid, contractor) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:contractors, :add, contractor})

    response
  end

  def invoices(uuid) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:invoices, :get})

    response
  end

  def add_invoice(uuid, invoice) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:invoices, :add, invoice})

    response
  end

  @impl GenServer
  def init(opts) do
    uuid = Keyword.fetch!(opts, :uuid)
    Logger.info("Starting invoicing service for user #{uuid}")
    {:ok, opts, {:continue, :setup}}
  end

  @impl GenServer
  def handle_continue(:setup, opts) do
    uuid = Keyword.fetch!(opts, :uuid)
    Logger.info("Loading user's data from DB")

    state =
      DB.get(:users_data, uuid)
      |> case do
        nil ->
          Logger.info("Creating new data storage for user #{uuid}")
          state = %__MODULE__{uuid: uuid}
          DB.insert(uuid, state)
          state

        state ->
          state
      end

    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:contractors, :get}, _from, %__MODULE__{contractors: contractors} = state) do
    Logger.info("Getting all contractors")
    {:reply, {:ok, contractors}, state}
  end

  @impl GenServer
  def handle_call(
        {:contractors, :add, %Structs.Contractor{} = contractor},
        _from,
        %__MODULE__{uuid: uuid} = state
      ) do
    Logger.info("Adding new contractor #{inspect(contractor)}")

    updated_state = Map.update!(state, :contractors, &:erlang.++(&1, [contractor]))

    :ok = DB.update(uuid, updated_state)
    {:reply, :ok, updated_state}
  end

  @impl GenServer
  def handle_call({:invoices, :get}, _from, %__MODULE__{invoices: invoices} = state) do
    Logger.info("Getting all invoices")
    {:reply, {:ok, invoices}, state}
  end

  @impl GenServer
  def handle_call(
        {:invoices, :add, %Invoice{} = invoice},
        _from,
        %__MODULE__{uuid: uuid} = state
      ) do
    Logger.info("Adding new invoice #{inspect(invoice)}")

    updated_state = Map.update!(state, :invoices, &:erlang.++(&1, [invoice]))

    :ok = DB.update(uuid, updated_state)
    {:reply, :ok, updated_state}
  end

  @impl InvoicingSystem.DB.Entity
  def table(), do: :users_data
end
