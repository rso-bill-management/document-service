defmodule InvoicingSystem.API.InvoicesControllerTest do
  use ExUnitFixtures
  use InvoicingSystem.API.ConnCase
  use InvoicingSystem.DB.TestHelpers.DB
  alias InvoicingSystem.API.TestHelpers.Database, as: DbHelper

  import Mock

  def authentication(conn, _) do
    alias InvoicingSystem.IAM

    {:ok, {user_uuid, user}} = IAM.Users.get(username: "user1")

    Plug.Conn.assign(
      conn,
      :user,
      Map.merge(Map.from_struct(user), %{
        uuid: user_uuid
      })
    )
  end

  deffixture init_users(), scope: :module, autouse: true do
    InvoicingSystem.TestHelpers.Users.init_users()
  end

  deffixture system(init_users), autouse: true do
    DbHelper.init_db(init_users)

    {:ok, _} = Application.ensure_all_started(:invoicing_iam)
    {:ok, _} = Application.ensure_all_started(:invoicing_invoices)

    on_exit(fn ->
      Application.stop(:invoicing_iam)
      Application.stop(:invoicing_invoices)
      Application.stop(:invoicing_db)
    end)

    # application is started just once and there is no need to clean state between tests
    {:ok, _} = Application.ensure_all_started(:invoicing_api)
    :ok
  end

  setup_with_mocks([
    {InvoicingSystem.API.Plugs.Authenticate, [], call: &authentication/2}
  ]) do
    :ok
  end

  describe "contractors:" do
    test "can get contractors", %{conn: conn} do
      conn |> get("/invoicing/contractors") |> json_response(:ok)
    end

    test "can add contractor", %{conn: conn} do
      contractor = %{
        tin: "123456789",
        name: "Hurt-Detal Jan Kowalski",
        town: "Warszawa",
        street: "Obozowa 1/12",
        postalCode: "01-123"
      }

      conn |> post("/invoicing/contractors", contractor) |> json_response(:ok)
      conn |> get("/invoicing/contractors") |> json_response(:ok)
    end
  end

  describe "predefined items:" do
    test "can get predefined items", %{conn: conn} do
      conn |> get("/invoicing/predefined_items") |> json_response(:ok)
    end

    test "can add a predefined item", %{conn: conn} do
      predefined_item = %{
        title: "Gwoździe",
        vat: 23,
        unit: "kg",
        unitNettoPrice: 123.12,
        count: 1.24
      }

      conn |> post("/invoicing/predefined_items", predefined_item) |> json_response(:ok)
      conn |> get("/invoicing/predefined_items") |> json_response(:ok)
    end
  end

  describe "sellers" do 
    test "can set seller", %{conn: conn}  do 
      seller = %{
        tin: "123456789",
        companyName: "Hurt-Detal Jan Kowalski",
        accountNumber: "123 000 000 000",
        street: "Obozowa 1/12",
        town: "Warszawa",
        postalCode: "01-123"
      }


      conn |> post("/invoicing/set_seller", seller) |> json_response(:ok)
    end
  end
end
