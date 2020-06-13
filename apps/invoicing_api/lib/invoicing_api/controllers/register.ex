defmodule InvoicingSystem.API.RegisterController do
    use InvoicingSystem.API, :controller
    
    alias InvoicingSystem.IAM.Users
  
    def register(conn, %{"username" => username, "password" => password}) do
        case Users.add(username: username, password: password) do
            :ok -> 
                conn
                |> put_status(:created)
                |> json(%{created: true})
            {:error, arr} ->
                conn
                |> put_status(:conflict)
                |> json(%{errors: arr})
        end
    end
end
