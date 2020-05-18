defmodule Invoicing.API.Views.ResultMapper do
  def map_result({:ok, body}), do: {:ok, body}
  def map_result(:ok), do: {:ok, status: :ok}
  def map_result({:error, reason} = error), do: {status(reason), error}

  defp status(:not_found), do: :not_found
  defp status(:already_exists), do: :conflict
  defp status(_), do: :bad_request
end
