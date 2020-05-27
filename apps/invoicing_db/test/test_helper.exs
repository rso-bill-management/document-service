Application.ensure_all_started(:invoicing_db)

Ecto.Adapters.SQL.Sandbox.mode(InvoicingSystem.DB.Repo, :manual)
ExUnitFixtures.start()
ExUnit.start()
