defmodule InvoicingSystem.API.StatusController do
  use InvoicingSystem.API, :controller

  # used by frontend to refresh the authorization token
  def status(conn, %{}) do
    json_resp({:ok, %{status: :ok}}, conn)
  end
end
