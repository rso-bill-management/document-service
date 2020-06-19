defmodule InvoicingSystem.Invoices.ServiceTest do
  use ExUnitFixtures
  use ExUnit.Case
  use InvoicingSystem.DB.TestHelpers.DB

  alias InvoicingSystem.Invoicing.Service
  alias InvoicingSystem.Invoicing.Structs.Contractor
  alias InvoicingSystem.Invoicing.Invoice

  @uuid UUID.uuid4()

  deffixture system(), autouse: true do
    {:ok, _} = Service.start_link(uuid: @uuid)
    # sync on GenServer startup
    _ = Service.contractors(@uuid)
  end

  deffixture contractor() do
    %Contractor{
      name: "Contractor 1",
      tin: "12345678",
      town: "Warszawa",
      street: "Główna 1",
      postalCode: "00-001"
    }
  end

  deffixture invoice() do
    %Invoice{}
  end

  describe "contractors:" do
    test "can get contractors when state is empty" do
      {:ok, []} = Service.contractors(@uuid)
    end

    @tag fixtures: [:contractor]
    test "can add contractor", %{contractor: contractor} do
      :ok = Service.add_contractor(@uuid, contractor)
      {:ok, [^contractor]} = Service.contractors(@uuid)
    end
  end

  describe "invoices:" do
    test "can get invoices when state is empty" do
      {:ok, []} = Service.invoices(@uuid)
    end

    @tag fixtures: [:invoice]
    test "can add invoice", %{invoice: invoice} do
      :ok = Service.add_invoice(@uuid, invoice)
      {:ok, [^invoice]} = Service.invoices(@uuid)
    end
  end
end
