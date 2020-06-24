defmodule InvoicingSystem.Invoicing.Service.Core.Test do
  use ExUnitFixtures
  use ExUnit.Case

  alias InvoicingSystem.Invoicing.Service
  alias InvoicingSystem.Invoicing.Service.Core
  alias InvoicingSystem.Invoicing.Structs.Contractor
  alias InvoicingSystem.Invoicing.Invoice

  @uuid UUID.uuid4()

  deffixture init_state(), autouse: true do
    %Service{uuid: @uuid}
  end

  @contractor_opts [
    name: "Contractor ABC",
    tin: "01234567",
    town: "Warszawa",
    street: "Wiejska 1",
    postalCode: "00-001"
  ]

  @invoice_opts [
    uuid: UUID.uuid4(),
    positions: [],
    contractor: []
  ]

  describe "contractors:" do
    test "can get all contractors", %{init_state: state} do
      {:ok, contractors} = Core.get(state, :contractors)
      assert is_list(contractors)
    end

    test "can add a contractor", %{init_state: state} do
      {:ok, [{:update, @uuid, updated_state}], %Service{} = updated_state} =
        Core.add(state, :contractor, @contractor_opts)

      {:ok, [%Contractor{}]} = Core.get(updated_state, :contractors)
    end
  end

  describe "invoices:" do
    test "can get all invoices", %{init_state: state} do
      {:ok, invoices} = Core.get(state, :invoices)
      assert is_map(invoices)
    end

    test "can add an invoice", %{init_state: state} do
      invoice_uuid = Keyword.fetch!(@invoice_opts, :uuid)

      {:ok, [{:update, @uuid, updated_state}], %Service{} = updated_state} =
        Core.add(state, :invoice, @invoice_opts)

      {:ok, %{^invoice_uuid => %Invoice{}}} = Core.get(updated_state, :invoices)
    end

    test "can automatically establish numbers for invoices", %{init_state: init_state} do
      uuids = Enum.zip(Range.new(1, 10), Stream.repeatedly(&UUID.uuid4/0))

      state =
        uuids
        |> Enum.reduce(init_state, fn {_no, uuid}, state ->
          invoice_opts = Keyword.merge(@invoice_opts, uuid: uuid)
          {:ok, _, updated_state} = Core.add(state, :invoice, invoice_opts)
          updated_state
        end)

      Enum.each(uuids, fn {no, uuid} ->
        assert {:ok, %{^uuid => %Invoice{number: ^no}}} = Core.get(state, :invoices)
      end)
    end
  end
end
