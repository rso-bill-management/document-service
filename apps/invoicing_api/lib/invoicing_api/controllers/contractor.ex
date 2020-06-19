defmodule InvoicingSystem.API.ContractorController do
    use InvoicingSystem.API, :controller
  
    def index(conn, %{}) do
      json_resp({:ok, %{status: :ok}}, conn)
    end
end