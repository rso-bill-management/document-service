defimpl Jason.Encoder, for: [MapSet] do
  def encode(set, opts) do
    Jason.Encode.list(Enum.to_list(set), opts)
  end
end

defimpl Jason.Encoder, for: [Tuple] do
  def encode({_k, _v} = tuple, opts) do
    Jason.Encode.keyword([tuple], opts)
  end

  def encode(tuple, opts) do
    Jason.Encode.list(Tuple.to_list(tuple), opts)
  end
end

defmodule InvoicingSystem.Utils.Encoding do
  def encode_binary(nil), do: nil

  def encode_binary(bin) when is_binary(bin),
    do: Base.encode16(bin, case: :lower) |> String.slice(0..16)
end
