defmodule InvoicingSystem.DB do
  require InvoicingSystem.DB.Entity
  alias InvoicingSystem.DB.Repo

  InvoicingSystem.DB.Entity.entity(:users)
  InvoicingSystem.DB.Entity.entity(:invoices)

  def execute(actions) do
    Repo.transaction(fn ->
      Enum.each(actions, &do_execute/1)
    end)
    |> case do
      {:ok, :ok} ->
        :ok

      error ->
        error
    end
  end

  def insert(uuid, %{__struct__: struct_name} = struct) when is_atom(struct_name) do
    struct_name
    |> apply(:table, [])
    |> insert(uuid, struct)
  end

  def update(uuid, %{__struct__: struct_name} = struct) when is_atom(struct_name) do
    struct_name
    |> apply(:table, [])
    |> update(uuid, struct)
  end

  defp do_execute({:add, table, uuid, data}), do: insert(table, uuid, data)
  defp do_execute({:add, uuid, entity}), do: insert(uuid, entity)
  defp do_execute({:update, uuid, entity}), do: update(uuid, entity)
  defp do_execute({:delete, table, uuid}), do: delete(table, uuid)
end
