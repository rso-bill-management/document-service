defmodule InvoicingSystem.DB.Encryption do
  use InvoicingSystem.DB.Entity

  defstruct [:key]

  def new() do
    {:ok, key} = ExCrypto.generate_aes_key(:aes_256, :bytes)
    %__MODULE__{key: key}
  end

  def encrypt(%__MODULE__{key: key}, data) do
    {:ok, {_init_vec, _cipher_text} = encrypted} = ExCrypto.encrypt(key, data)
    :erlang.term_to_binary(encrypted)
  end

  def decrypt(%__MODULE__{key: key}, data) do
    {init_vec, cipher_text} = :erlang.binary_to_term(data)
    {:ok, decrypted} = ExCrypto.decrypt(key, init_vec, cipher_text)
    decrypted
  end

  def table(), do: :keys
end
