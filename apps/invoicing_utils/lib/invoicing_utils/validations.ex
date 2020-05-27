defmodule InvoicingSystem.Utils.Validators.TaxIdentificationNumner do
  use Vex.Validator

  def validate(_value, _opts) do
    :ok
  end
end

defmodule InvoicingSystem.Utils.Validators.InnerStruct do
  use Vex.Validator

  def validate(%struct{} = value, struct) do
    value |> Vex.validate() |> translate_result()
  end

  def validate(_, struct) when is_atom(struct),
    do: {:error, "must be a struct of #{inspect(struct)}"}

  def translate_result({:ok, _}), do: :ok
  def translate_result([{:error, _, _} | _]), do: {:error, "invalid inner struct"}
end
