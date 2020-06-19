defmodule InvoicingSystem.IAM.Users.User do
  use InvoicingSystem.DB.Entity

  @derive {Jason.Encoder, except: [:password_derivative]}
  defstruct [:username, :name, :surname, :password_derivative]

  @validations [
    username: [
      length: [min: 4],
      format: ~r/^[[:alpha:]][[:alnum:]]+$/
    ],
    # name: [
    #   length: [min: 2],
    #   format: ~r/^[[:upper:]][[:lower:]]+$/u
    # ],
    # surname: [
    #   length: [min: 2],
    #   format: ~r/^[[:upper:]][[:lower:]]+$/u
    # ],
    password: [
      length: [min: 6, allow_nil: true],
      format: [with: ~r/^[[:graph:]]+$/u, allow_nil: true]
    ]
  ]

  def new(opts) do
    with {:ok, _} <- Vex.validate(opts, @validations) do
      password_derivative =
        case Keyword.fetch(opts, :password) do
          # TODO: make pure
          {:ok, password} -> Argon2.hash_pwd_salt(password)
          _ -> Keyword.fetch!(opts, :password_derivative)
        end

      user = struct(__MODULE__, Keyword.put(opts, :password_derivative, password_derivative))
      {:ok, user}
    end
  end

  @impl InvoicingSystem.DB.Entity
  def table(), do: :users
end
