defmodule InvoicingSystem.API.RegisterController do
    use InvoicingSystem.API, :controller
  
    def register(conn, %{"username" => username, "password" => password, "email" => email}) do
        json_resp({:ok, %{status: :ok}}, conn)
    end
end
  