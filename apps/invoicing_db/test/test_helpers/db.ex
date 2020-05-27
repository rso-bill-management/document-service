defmodule InvoicingSystem.DB.TestHelpers.DB do
  use ExUnit.CaseTemplate

  setup do
    setup_db()
    :ok
  end

  defp setup_db() do
    {:ok, _} = Application.ensure_all_started(:invoicing_db)

    # necessary, otherwise db stores some artifacts
    Ecto.Adapters.SQL.Sandbox.mode(InvoicingSystem.DB.Repo, :manual)

    :ok = Ecto.Adapters.SQL.Sandbox.checkout(InvoicingSystem.DB.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(InvoicingSystem.DB.Repo, {:shared, self()})

    on_exit(fn ->
      Application.stop(:invoicing_db)
    end)
  end
end
