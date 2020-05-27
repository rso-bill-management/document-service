defmodule InvoicingSystem.API.LoginController do
  use InvoicingSystem.API, :controller
  alias InvoicingSystem.IAM.Authenticator

  def login(conn, %{"username" => username, "password" => password}) do
    Authenticator.authenticate(username, password)
    |> map_result()
    |> json_resp(conn)
  end
end
