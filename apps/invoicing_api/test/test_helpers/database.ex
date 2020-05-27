defmodule InvoicingSystem.API.TestHelpers.Database do
  alias InvoicingSystem.DB

  def init_db(init_data) do
    :ok = DB.execute(Enum.map(init_data, fn {uuid, data} -> {:add, uuid, data} end))
  end
end
