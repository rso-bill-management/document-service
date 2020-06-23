defmodule InvoicingSystem.API.RegisterController do
  use InvoicingSystem.API, :controller

  alias InvoicingSystem.IAM.Users
  alias InvoicingSystem.Invoicing.Supervisor

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

    with :ok <- Users.add(username: username, name: name, surname: surname, password: password),
         {:ok, {uuid, _}} <- Users.get(username: username),
         {:ok, _} <- Supervisor.new_user(uuid) do
      conn
      |> put_status(:created)
      |> json(%{created: true})
    else
      {:error, arr} ->
        conn
        |> put_status(:conflict)
        |> json(%{errors: arr})
    end
  end
end
