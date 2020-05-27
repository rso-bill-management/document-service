defmodule InvoicingSystem.DB.Entity do
  @callback table() :: atom()

  defmacro __using__([]) do
    quote do
      @behaviour InvoicingSystem.DB.Entity
    end
  end

  defmacro entity(table) do
    table_name = Atom.to_string(table)

    quote do
      defmodule unquote(table) do
        use Ecto.Schema
        import Ecto.Changeset

        @primary_key {:uuid, :binary_id, autogenerate: false}

        schema unquote(table_name) do
          field(:data, :binary)
        end

        def changeset(%unquote(table){uuid: uuid, data: data}) do
          change(%unquote(table){uuid: uuid}, %{data: data})
        end
      end

      def get(unquote(table)) do
        unquote(table)
        |> InvoicingSystem.DB.Repo.all()
        |> Enum.map(&entity_to_struct/1)
      end

      def get(unquote(table), uuid) when is_binary(uuid) do
        unquote(table)
        |> InvoicingSystem.DB.Repo.get!(uuid)
        |> entity_to_struct()
      end

      def delete(unquote(table), uuid) when is_binary(uuid) do
        {:ok, _} =
          struct!(unquote(table), uuid: uuid)
          |> InvoicingSystem.DB.Repo.delete()

        :ok
      end

      defp insert(unquote(table), uuid, struct) do
        {:ok, _} =
          {uuid, struct}
          |> struct_to_entity(unquote(table))
          |> InvoicingSystem.DB.Repo.insert()

        :ok
      end

      defp update(unquote(table), uuid, struct) do
        {:ok, _} =
          {uuid, struct}
          |> struct_to_entity(unquote(table))
          |> unquote(table).changeset()
          |> InvoicingSystem.DB.Repo.update()

        :ok
      end

      defp struct_to_entity({uuid, struct}, unquote(table)),
        do: struct!(unquote(table), uuid: uuid, data: :erlang.term_to_binary(struct))

      defp entity_to_struct(%unquote(table){uuid: uuid, data: data}),
        do: {uuid, :erlang.binary_to_term(data)}
    end
  end
end
