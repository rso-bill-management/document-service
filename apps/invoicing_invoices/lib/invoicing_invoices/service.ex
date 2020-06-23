defmodule InvoicingSystem.Invoicing.Service do
  use GenServer
  require Logger

  use InvoicingSystem.DB.Entity
  alias InvoicingSystem.DB
  alias InvoicingSystem.Invoicing.Service.Core

  defstruct [
    :uuid,
    contractors: [],
    invoices: %{},
    items: [],
    seller: %{}
  ]

  def start_link(opts) do
    uuid = Keyword.fetch!(opts, :uuid)
    GenServer.start_link(__MODULE__, opts, name: String.to_atom(uuid))
  end

  def contractors(uuid) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:get, :contractors})

    response
  end

  def add_contractor(uuid, opts) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:add, :contractor, opts})

    response
  end

  def invoices(uuid) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:get, :invoices})

    response
  end

  def add_invoice(uuid, opts) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:add, :invoice, opts})

    response
  end

  def predefined_items(uuid) do
    {[{_node, response}], _} = GenServer.multi_call(String.to_existing_atom(uuid), {:get, :items})

    response
  end

  def add_predefined_item(uuid, opts) do
    {[{_node, response}], _} =
      GenServer.multi_call(String.to_existing_atom(uuid), {:add, :item, opts})

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
  def handle_call({:get, entity}, _from, %__MODULE__{} = state) do
    Logger.info("Getting all #{Atom.to_string(entity)}")
    response = Core.get(state, entity)
    {:reply, response, state}
  end

  @impl GenServer
  def handle_call(
        {:add, entity, opts},
        _from,
        %__MODULE__{} = state
      ) do
    Logger.info("Adding new #{Atom.to_string(entity)}: #{inspect(opts)}")

    {:ok, db_updates, updated_state} = Core.add(state, entity, opts)

    :ok = DB.execute(db_updates)
    {:reply, :ok, updated_state}
  end

  @impl InvoicingSystem.DB.Entity
  def table(), do: :users_data
end
