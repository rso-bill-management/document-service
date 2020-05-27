defmodule InvoicingSystem.TestHelpers.Users do
  alias InvoicingSystem.IAM.Users
  alias InvoicingSystem.IAM.Users.User

  def init_users() do
    stream = Stream.repeatedly(&UUID.uuid4/0)

    [
      User.new(username: "user1", name: "John", surname: "Smith", password: "qwerty"),
      User.new(username: "user2", name: "Jack", surname: "Jones", password: "qwerty1")
    ]
    |> Enum.map(&elem(&1, 1))
    |> (&Enum.zip(stream, &1)).()
    # adding root user in order to save time - normally root user would be added automatically
    |> Kernel.++([root_user()])
  end

  def root_user() do
    {:ok, root} = User.new(username: "root", name: "John", surname: "Smith", password: "password")
    {Users.root_user_uuid(), root}
  end
end
