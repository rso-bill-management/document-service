defmodule InvoicingSystem.API.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  alias InvoicingSystem.IAM.Authenticator

  def init([]), do: []

  def call(%Plug.Conn{} = conn, _) do
    with {:ok, token} <- get_token(conn),
         {:ok, claims} <-
           Authenticator.validate_token(token) do
      assign(conn, :user, claims)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> json({:error, :unauthorized})
        |> halt()
    end
  end

  def get_token(conn) do
    with [bearer_and_token] <- get_req_header(conn, "authorization") do
      token =
        bearer_and_token
        |> String.trim_leading()
        |> String.trim_leading("Bearer")
        |> String.trim_leading()

      {:ok, token}
    end
  end
end
