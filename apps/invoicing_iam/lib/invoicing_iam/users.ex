defmodule InvoicingSystem.IAM.Users do
  @moduledoc """
  A GenServer that takes responsibility for management of users.
  """

  use GenServer

  alias InvoicingSystem.IAM.Users.Core
  alias InvoicingSystem.IAM.Users.User
  alias InvoicingSystem.DB
  alias UUID

  require Logger

  @root_user_uuid "00000000-0000-0000-0000-000000000000"

  defstruct users: %{}

  # move somewhere to reuse
  @type uuid_t :: String.t()
  @type t() :: %__MODULE__{
          users: %{uuid_t() => User.t()}
        }

  def start_link(users \\ []),
    do: GenServer.start_link(__MODULE__, users, name: __MODULE__)

  def init(users) do
    Logger.info("Starting #{inspect(__MODULE__)}")
    {:ok, struct!(__MODULE__, users: Map.new(users)), {:continue, :setup}}
  end

  def handle_continue(:setup, %__MODULE__{users: users} = state) do
    # NOTE: may cause error logs when testing
    #
    # If a module is not used in a test and has not properly initialised
    # before the test ends, trying to connect to a db that does not exists causes errors.
    # Tests should pass nevertheless.

    Logger.info("Loading users from DB")

    updated_users =
      DB.get(:users)
      |> Map.new()
      |> (&Map.merge(users, &1)).()
      |> inject_root_user()

    Logger.info("Started #{inspect(__MODULE__)}")
    {:noreply, %{state | users: updated_users}}
  end

  def get(opts \\ []) do
    GenServer.call(__MODULE__, {:get, opts})
  end

  def add(opts) do
    GenServer.call(__MODULE__, {:add, opts})
  end

  def update(uuid, changes) do
    GenServer.call(__MODULE__, {:update, uuid, changes})
  end

  def delete(uuid) do
    GenServer.call(__MODULE__, {:delete, uuid})
  end

  def root_user_uuid(), do: @root_user_uuid

  ### CALL HANDLERS
  def handle_call({:get, []}, _from, state) do
    {:reply, state.users, state}
  end

  def handle_call({:get, opts}, _from, state) do
    {:reply, Core.get_user(state, opts), state}
  end

  def handle_call({:add, opts}, _from, state) do
    with uuid <- UUID.uuid4(),
         {:ok, db_updates, updated_state} <- Core.add_user(state, uuid, opts) do
      :ok = DB.execute(db_updates)
      Logger.info("Successfully created user #{uuid}.")
      {:reply, :ok, updated_state}
    else
      error ->
        Logger.warn("Could not create user. Reason: #{inspect(error)}")
        {:reply, error, state}
    end
  end

  def handle_call({:update, uuid, changes}, _from, state) do
    with {:ok, db_updates, updated_state} <- Core.update_user(state, uuid, changes) do
      :ok = DB.execute(db_updates)
      Logger.debug("Successfully updated user #{uuid}.")
      {:reply, :ok, updated_state}
    else
      error ->
        Logger.warn("Could not update user. Reason: #{inspect(error)}")
        {:reply, error, state}
    end
  end

  def handle_call({:delete, uuid}, _from, state) do
    with {:ok, db_updates, updated_state} <- Core.delete_user(state, uuid) do
      :ok = DB.execute(db_updates)
      Logger.debug("Successfully deleted user #{uuid}.")
      {:reply, :ok, updated_state}
    else
      error ->
        Logger.warn("Could not delete user. Reason: #{inspect(error)}")
        {:reply, error, state}
    end
  end

  defp inject_root_user(init_users) do
    if Map.has_key?(init_users, @root_user_uuid) do
      init_users
    else
      Logger.warn("Injecting root user")

      {:ok, root_user} =
        User.new(username: "root", name: "Root", surname: "Root", password: "password")

      :ok = DB.execute([{:add, @root_user_uuid, root_user}])

      Map.put_new(init_users, @root_user_uuid, root_user)
    end
  end
end
