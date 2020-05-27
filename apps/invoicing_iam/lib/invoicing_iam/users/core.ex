defmodule InvoicingSystem.IAM.Users.Core do
  alias InvoicingSystem.IAM.Users
  alias InvoicingSystem.IAM.Users.User
  alias InvoicingSystem.Utils.Structs.Changeset

  def get_user(%Users{users: users}, uuid: uuid) do
    users
    |> Map.fetch(uuid)
    |> map_find_result()
  end

  def get_user(%Users{users: users}, username: username) do
    users
    |> Enum.find(:error, fn {_, user} -> user.username == username end)
    |> map_find_result()
  end

  def add_user(%Users{users: users} = state, uuid, opts) do
    with {:ok, user} <- User.new(opts),
         :ok <- Changeset.check_duplicated_entity(users, {uuid, user}, :username) do
      updated_users = Map.put_new(users, uuid, user)
      {:ok, [{:add, uuid, user}], %{state | users: updated_users}}
    end
  end

  def update_user(%Users{users: users} = state, uuid, changes) do
    with {:ok, user} <- get_user(state, uuid: uuid),
         {:ok, changes} <-
           Changeset.validate_changes_fields(%User{}, changes,
             except: [:password_derivative],
             additional: [:password]
           ),
         new_user_opts <- Keyword.merge(Map.to_list(user), changes),
         {:ok, updated_user} <- User.new(new_user_opts),
         :ok <- Changeset.check_duplicated_entity(users, {uuid, updated_user}, :username) do
      {
        :ok,
        [{:update, uuid, updated_user}],
        %{state | users: Map.replace!(users, uuid, updated_user)}
      }
    end
  end

  def delete_user(%Users{users: users} = state, uuid) do
    case Map.pop(users, uuid) do
      {nil, _} -> {:ok, [], state}
      {_, updated_users} -> {:ok, [{:delete, :users, uuid}], %{state | users: updated_users}}
    end
  end

  defp map_find_result(:error), do: {:error, :not_found}
  defp map_find_result({:ok, %User{} = user}), do: {:ok, user}
  defp map_find_result({uuid, %User{} = user}), do: {:ok, {uuid, user}}
end
