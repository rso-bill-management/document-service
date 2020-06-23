defmodule InvoicingSystem.Invoices.SupervisorTest do
  use ExUnitFixtures
  use ExUnit.Case
  use InvoicingSystem.DB.TestHelpers.DB

  alias InvoicingSystem.Invoicing.Service
  alias InvoicingSystem.IAM.Users

  deffixture system(), autouse: true do
    {:ok, _} = Application.ensure_all_started(:invoicing_iam)
    {:ok, _} = Application.ensure_all_started(:invoicing_invoices)

    on_exit(fn ->
      Application.stop(:invoicing_iam)
      Application.stop(:invoicing_invoices)
    end)
  end

  test "started for already defined users" do
    users =
      Users.get()
      |> Map.keys()

    assert length(users) > 0

    users
    |> Enum.each(fn uuid ->
      {:ok, []} = Service.contractors(uuid)
    end)
  end
end
