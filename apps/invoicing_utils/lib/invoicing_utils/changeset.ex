defmodule InvoicingSystem.Utils.Structs.Changeset do
  def check_duplicated_entity(entities, {uuid, entity}, compared_field) do
    if Enum.all?(entities, fn {current_uuid, current_entity} ->
         Map.fetch!(current_entity, compared_field) != Map.fetch!(entity, compared_field) or
           current_uuid == uuid
       end) do
      :ok
    else
      {:error, :already_exists}
    end
  end

  def validate_changes_fields(struct, changes, opts \\ []) do
    defaults = [except: [], additional: []]
    opts = Keyword.merge(defaults, opts)

    keys =
      struct
      |> Map.keys()
      |> Kernel.--(Keyword.fetch!(opts, :except))
      |> Kernel.++(Keyword.fetch!(opts, :additional))
      |> Enum.map(&{&1, Atom.to_string(&1)})

    changes
    |> Enum.reduce([], &map_field(keys, &1, &2))
    |> create_result()
  end

  defp map_field(keys, {key, value}, acc) do
    keys
    |> Enum.find(key_comparator(key))
    |> create_partial_result(value)
    |> Kernel.++(acc)
  end

  defp key_comparator(key) when is_atom(key), do: fn {a, _s} -> key == a end
  defp key_comparator(key) when is_binary(key), do: fn {_a, s} -> key == s end

  defp create_partial_result(nil, _value), do: []
  defp create_partial_result({key, _}, value), do: [{key, value}]

  defp create_result([]), do: {:error, :fields_not_found}
  defp create_result(changes), do: {:ok, changes}
end
