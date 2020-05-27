defmodule InvoicingSystem.DB.SmokeTest do
  use ExUnit.Case
  alias InvoicingSystem.DB
  alias InvoicingSystem.IAM.Users.User

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(InvoicingSystem.DB.Repo)
  end

  @uuid UUID.uuid4()
  @user User.new(username: "username", name: "Name", surname: "Surname", password: "password")
        |> elem(1)

  test "database smoke test" do
    # insert a user
    DB.insert(@uuid, @user)

    # get one user
    DB.get(:users, @uuid)

    # update a user
    DB.update(@uuid, %{@user | name: "John"})

    # add another user
    DB.insert(UUID.uuid4(), @user)

    # try to insert a user that already exists
    catch_error(DB.insert(@uuid, @user) == Ecto.ConstraintError)

    # get all users
    assert length(DB.get(:users)) == 2

    # delete user
    :ok = DB.delete(:users, @uuid)
  end

  test "can execute actions" do
    actions = [
      {:add, @uuid, @user},
      {:update, @uuid, %{@user | name: "John"}},
      {:add, UUID.uuid4(), @user},
      {:delete, :users, @uuid}
    ]

    assert DB.execute(actions) == :ok
  end
end
