defmodule InvoicingSystem.IAM.UsersCoreTest do
  use ExUnit.Case, async: true

  alias InvoicingSystem.IAM.Users
  alias InvoicingSystem.IAM.Users.Core
  alias InvoicingSystem.IAM.Users.User

  @new_user_data [
    username: "username",
    name: "John",
    surname: "Smith",
    password: "Some_password_@#$%"
  ]

  @new_uuid UUID.uuid4()

  @state %Users{}

  describe "can create new user:" do
    test "from valid data" do
      assert {:ok, _} = User.new(@new_user_data)
    end

    test "from unicode data" do
      user_data = [
        username: "username",
        name: "Włodzimierz",
        surname: "Wójcik",
        password: "Some_password_@#$%ąęśćźż"
      ]

      assert {:ok, _} = User.new(user_data)
    end

    test "fails to create user from invalid data" do
      expected_errors = [
        {:error, :username, :length, "must have a length of at least 4"},
        {:error, :username, :format, "must have the correct format"},
        {:error, :name, :format, "must have the correct format"},
        {:error, :surname, :length, "must have a length of at least 2"},
        {:error, :surname, :format, "must have the correct format"},
        {:error, :password, :length, "must have a length of at least 6"},
        {:error, :password, :format, "must have the correct format"}
      ]

      {:error, errors} =
        User.new(
          username: "u",
          name: "john",
          password: " "
        )

      assert length(errors) == length(expected_errors)
      assert Enum.all?(errors, &Enum.member?(expected_errors, &1))
    end

    test "adds the user to state and produces valid db updates" do
      {:ok, db_updates, updated_state} = Core.add_user(@state, @new_uuid, @new_user_data)

      assert {:ok, user} = Map.fetch(updated_state.users, @new_uuid)
      assert [{:add, @new_uuid, user}] == db_updates
    end

    test "fails to add user with duplicated username" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      assert {:error, :already_exists} == Core.add_user(state, UUID.uuid4(), @new_user_data)
    end
  end

  describe "can update user: " do
    test "can update user by uuid" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:ok, db_updates, updated_state} = Core.update_user(state, @new_uuid, username: "username1")

      {:ok, updated_user} = Core.get_user(updated_state, uuid: @new_uuid)
      assert updated_user.username == "username1"
      assert db_updates == [{:update, @new_uuid, updated_user}]
    end

    test "fails to change username to an already existing one" do
      other_uuid = UUID.uuid4()
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:ok, _, state} = Core.update_user(state, @new_uuid, username: "username1")
      {:ok, _, state} = Core.add_user(state, other_uuid, @new_user_data)

      assert Core.update_user(state, other_uuid, username: "username1") ==
               {:error, :already_exists}
    end

    test "can update either by atoms or by strings as field types" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:ok, db_updates, updated_state} = Core.update_user(state, @new_uuid, username: "username1")

      {:ok, updated_user} = Core.get_user(updated_state, uuid: @new_uuid)
      assert updated_user.username == "username1"
      assert db_updates == [{:update, @new_uuid, updated_user}]
    end

    test "updates only given fields and leaves out invalid keys" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:ok, user} = Core.get_user(state, uuid: @new_uuid)

      {:ok, _, updated_state} =
        Core.update_user(state, @new_uuid, name: "Jack", invalid_key: :invalid_value)

      {:ok, updated_user} = Core.get_user(updated_state, uuid: @new_uuid)
      assert updated_user == %{user | name: "Jack"}
    end

    test "fails when trying to update with invalid values" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:error, _} = Core.update_user(state, @new_uuid, username: "")
    end

    test "fails when trying to update with non-exiting fields" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:error, :fields_not_found} = Core.update_user(state, @new_uuid, dupa: "kupa")
    end

    test "can update password" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:ok, user} = Core.get_user(state, uuid: @new_uuid)

      {:ok, [{:update, @new_uuid, updated_user}], _} =
        Core.update_user(state, @new_uuid, password: "password")

      assert user.password_derivative != updated_user.password_derivative
    end
  end

  describe "Can delete a user" do
    test "by uuid" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:ok, db_updates, updated_state} = Core.delete_user(state, @new_uuid)

      assert db_updates == [{:delete, :users, @new_uuid}]

      # when trying to delete an non-existing user, nothing happens
      assert {:ok, [], ^updated_state} = Core.delete_user(updated_state, @new_uuid)
    end

    test "and can then reuse username" do
      {:ok, _, state} = Core.add_user(@state, @new_uuid, @new_user_data)
      {:ok, _, updated_state} = Core.delete_user(state, @new_uuid)
      assert {:ok, _, _} = Core.add_user(updated_state, @new_uuid, @new_user_data)
    end
  end

  describe "Encoding" do
    test "encoded data does not include password derivative" do
      {:ok, user} = User.new(@new_user_data)
      map = Jason.encode!(user) |> Jason.decode!()
      assert not Map.has_key?(map, "password_derivative")
    end
  end
end
