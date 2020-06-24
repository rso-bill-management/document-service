defmodule InvoicingSystem.IAM.Authenticator do
  use Joken.Config

  alias InvoicingSystem.IAM.Users

  def authenticate(username, password) do
    with {:ok, {uuid, user}} <- Users.get(username: username),
         :ok <- verify_password(user.password_derivative, password),
         {:ok, token, claims} <- generate_token({uuid, user}) do
      {:ok, Map.put_new(claims, :token, token)}
    else
      {:error, :not_found} -> {:error, :unknown_user}
      error -> error
    end
  end

  def generate_token(claims) do
    claims
    |> claims()
    |> generate_and_sign()
  end

  def validate_token(token) do
    with {:ok, claims} <- verify_and_validate(token),
         %{
           "user_id" => uuid
         } <- claims,
         {:ok, user} <- Users.get(uuid: uuid) do
      {:ok,
       %{
         uuid: uuid,
         username: user.username,
         name: user.name,
         surname: user.surname
       }}
    end
  end

  defp claims(%{
         uuid: uuid,
         username: username,
         name: name,
         surname: surname
       }) do
    %{
      "user_id" => uuid,
      "username" => username,
      "name" => name,
      "surname" => surname
    }
  end

  defp claims({uuid, %Users.User{} = user}) do
    user
    |> Map.from_struct()
    |> Map.put_new(:uuid, uuid)
    |> claims()
  end

  def token_config() do
    default_claims(
      iss: "RSO",
      aud: "RSO",
      default_exp: 86_400
    )
  end

  defp verify_password(password_derivative, password) do
    if Argon2.verify_pass(password, password_derivative) do
      :ok
    else
      {:error, :invalid_password}
    end
  end
end
