defmodule InvoicingSystem.API.Plugs.RefreshToken do
  import Plug.Conn
  alias InvoicingSystem.IAM.Authenticator

  def init([]), do: []

  def call(%Plug.Conn{assigns: %{user: claims}} = conn, _) do
    with {:ok, token, _claims} <- Authenticator.generate_token(claims) do
      put_resp_header(conn, "authorization", token)
    end
  end
end
