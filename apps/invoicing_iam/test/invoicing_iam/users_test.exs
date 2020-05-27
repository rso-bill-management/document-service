defmodule InvoicingSystem.IAM.UsersTest do
  use ExUnitFixtures
  use ExUnit.Case
  use InvoicingSystem.DB.TestHelpers.DB
  alias InvoicingSystem.DB
  alias InvoicingSystem.IAM.Users

  deffixture system(), autouse: true do
    {:ok, _} = Users.start_link()
    # sync on GenServer startup
    _ = Users.get()
  end

  test "check if user genserver does not lose its data after restart" do
    user = [
      username: "user3",
      name: "Jan",
      surname: "Wójcik",
      password: "123456"
    ]

    # Ensure that DB is empty and user genserver has only root user in its state
    assert length(DB.get(:users)) == 1
    assert length(Map.keys(Users.get())) == 1

    Users.add(user)
    assert length(DB.get(:users)) == 2
    assert length(Map.keys(Users.get())) == 2

    # Stop and start genserver
    :ok = GenServer.stop(Users)
    {:ok, _} = Users.start_link()
    assert length(Map.keys(Users.get())) == 2
  end
end
