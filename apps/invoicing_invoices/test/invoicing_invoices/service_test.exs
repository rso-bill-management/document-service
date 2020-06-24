defmodule InvoicingSystem.Invoices.ServiceTest do
  use ExUnitFixtures
  use ExUnit.Case
  use InvoicingSystem.DB.TestHelpers.DB

  alias InvoicingSystem.Invoicing.Service

  @uuid UUID.uuid4()

  deffixture system(), autouse: true do
    {:ok, pid} = Service.start_link(uuid: @uuid)
    # sync on GenServer startup
    _ = Service.contractors(@uuid)
    pid
  end

  deffixture contractor() do
    [
      name: "Contractor 1",
      tin: "12345678",
      town: "Warszawa",
      street: "Główna 1",
      postalCode: "00-001"
    ]
  end

  deffixture invoice() do
    [
      uuid: UUID.uuid4(),
      contractor: [],
      positions: []
    ]
  end

  deffixture predefined_item() do
    [title: "Kaszanka"]
  end

  describe "contractors:" do
    test "can get contractors when state is empty" do
      assert {:ok, []} = Service.contractors(@uuid)
    end

    @tag fixtures: [:contractor]
    test "can add contractor", %{contractor: contractor} do
      :ok = Service.add_contractor(@uuid, contractor)
    end
  end

  describe "invoices:" do
    test "can get invoices when state is empty" do
      assert {:ok, %{}} = Service.invoices(@uuid)
    end

    @tag fixtures: [:invoice]
    test "can add invoice", %{invoice: invoice} do
      :ok = Service.add_invoice(@uuid, invoice)
    end
  end

  describe "items:" do
    test "can list all items" do
      assert {:ok, []} = Service.predefined_items(@uuid)
    end

    @tag fixtures: [:predefined_item]
    test "can add item", %{predefined_item: item} do
      :ok = Service.add_predefined_item(@uuid, item)
    end
  end

  @tag fixtures: [:predefined_item, :contractor, :invoice]
  test "can restore data", %{
    invoice: invoice,
    contractor: contractor,
    predefined_item: item,
    system: pid
  } do
    :ok = Service.add_contractor(@uuid, contractor)
    :ok = Service.add_invoice(@uuid, invoice)
    :ok = Service.add_predefined_item(@uuid, item)

    GenServer.stop(pid)
    {:ok, _} = Service.start_link(uuid: @uuid)

    assert {:ok, [_]} = Service.predefined_items(@uuid)
    assert {:ok, [_]} = Service.contractors(@uuid)
    assert {:ok, invoices} = Service.invoices(@uuid)
    assert length(Map.keys(invoices)) == 1
  end

  test "can set seller" do
    :ok = Service.set_seller(@uuid, tin: "123", city: "Warszawa")
  end
end
