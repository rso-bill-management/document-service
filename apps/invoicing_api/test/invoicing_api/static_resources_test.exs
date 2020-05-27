defmodule InvoicingSystem.API.StaticResourcesTest do
  use ExUnitFixtures
  use InvoicingSystem.API.ConnCase

  deffixture system(), autouse: true do
    {:ok, _} = Application.ensure_all_started(:invoicing_api)
    :ok
  end

  test "serves server api", %{conn: conn} do
    conn
    |> get("/server_api.yaml")
    |> response(:ok)
  end
end
