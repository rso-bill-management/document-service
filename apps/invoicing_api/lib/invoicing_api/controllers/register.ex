defmodule InvoicingSystem.API.RegisterController do
  use InvoicingSystem.API, :controller

  alias InvoicingSystem.IAM.Users

    case Users.add(username: username, password: password) do
      :ok ->
        conn
        |> put_status(:created)
        |> json(%{created: true})
  require Logger

  def register(
        conn,
        %{
          "username" => username,
          "password" => password,
          "name" => name,
          "surname" => surname
        } = user
      ) do
    Logger.info("Adding new user: #{inspect(user)}")
      {:error, arr} ->
        conn
        |> put_status(:conflict)
        |> json(%{errors: arr})
    end
  end
end
