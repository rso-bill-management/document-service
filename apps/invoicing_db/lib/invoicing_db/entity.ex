defmodule InvoicingSystem.DB.Entity do
  @callback table() :: atom()

  defmacro __using__([]) do
    quote do
      @behaviour InvoicingSystem.DB.Entity
    end
  end

  defmacro entity(table, opts \\ [encrypt: false]) do
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
        |> Enum.map(&entity_to_struct(&1, unquote(opts)))
      end

      def get!(unquote(table), uuid) when is_binary(uuid) do
        unquote(table)
        |> InvoicingSystem.DB.Repo.get!(uuid)
        |> entity_to_struct(unquote(opts))
      end

      def get(unquote(table), uuid) when is_binary(uuid) do
        unquote(table)
        |> InvoicingSystem.DB.Repo.get(uuid)
        |> entity_to_struct(unquote(opts))
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
          |> struct_to_entity(unquote(table), unquote(opts))
          |> InvoicingSystem.DB.Repo.insert()

        :ok
      end

      defp update(unquote(table), uuid, struct) do
        {:ok, _} =
          {uuid, struct}
          |> struct_to_entity(unquote(table), unquote(opts))
          |> unquote(table).changeset()
          |> InvoicingSystem.DB.Repo.update()

        :ok
      end

      defp struct_to_entity({uuid, struct}, unquote(table), encrypt: false),
        do: struct!(unquote(table), uuid: uuid, data: :erlang.term_to_binary(struct))

      defp entity_to_struct(%unquote(table){uuid: uuid, data: data}, encrypt: false),
        do: {uuid, :erlang.binary_to_term(data)}

      defp struct_to_entity({uuid, struct}, unquote(table), encrypt: true) do
        alias InvoicingSystem.DB.Encryption

        key =
          case get(:keys, uuid) do
            {uuid, key} ->
              key

            nil ->
              key = Encryption.new()
              :ok = insert(:keys, uuid, key)
              key
          end

        data = :erlang.term_to_binary(struct)
        encrypted = Encryption.encrypt(key, data)
        struct!(unquote(table), uuid: uuid, data: encrypted)
      end

      defp entity_to_struct(%unquote(table){uuid: uuid, data: data}, encrypt: true) do
        alias InvoicingSystem.DB.Encryption
        {_uuid, key} = get!(:keys, uuid)
        decrypted = Encryption.decrypt(key, data)

        {uuid, :erlang.binary_to_term(decrypted)}
      end

      defp entity_to_struct(nil, _), do: nil
    end
  end
end
