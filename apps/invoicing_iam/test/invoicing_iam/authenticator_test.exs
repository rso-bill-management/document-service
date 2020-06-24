defmodule InvoicingSystem.IAM.AuthenticatorTest do
  use ExUnitFixtures
  use ExUnit.Case
  use InvoicingSystem.DB.TestHelpers.DB

  alias InvoicingSystem.IAM.Authenticator
  alias InvoicingSystem.IAM.Users

  import Mock

  deffixture init_users(), scope: :module, autouse: true do
    InvoicingSystem.TestHelpers.Users.init_users()
  end

  deffixture system(init_users), autouse: true do
    {:ok, _} = Users.start_link(init_users)
  end

  describe "Given valid login data:" do
    test "creates a token" do
      assert {:ok, %{token: _}} = Authenticator.authenticate("user1", "qwerty")
    end

    @tag fixtures: [:init_users]
    test "returns valid uuid and username", %{init_users: [{uuid, _} | _]} do
      {:ok, result} = Authenticator.authenticate("user1", "qwerty")
      assert %{"user_id" => ^uuid, "username" => "user1"} = result
    end

    test "and validates the created token" do
      {:ok, %{"user_id" => uuid, token: token}} = Authenticator.authenticate("user1", "qwerty")

      assert {:ok, %{uuid: ^uuid, username: "user1", name: "John", surname: "Smith"}} =
               Authenticator.validate_token(token)
    end

    test "the token in invalidated after 24 hours" do
      token =
        with_mock Joken, [:passthrough], current_time: fn -> 0 end do
          {:ok, %{token: token}} = Authenticator.authenticate("user1", "qwerty")

          token
        end

      # forward 24h - 1s from issuance
      with_mock Joken, [:passthrough], current_time: fn -> 24 * 60 * 60 - 1 end do
        assert {:ok, _} = Authenticator.validate_token(token)
      end

      # forward 24h from issuance
      with_mock Joken, [:passthrough], current_time: fn -> 24 * 60 * 60 end do
        assert {:error, _} = Authenticator.validate_token(token)
      end
    end
  end

  test "given invalid user returns an error" do
    assert {:error, :unknown_user} = Authenticator.authenticate("not_john", "password")
  end

  test "given invalid password returns an error" do
    assert {:error, :invalid_password} = Authenticator.authenticate("user1", "other_password")
  end

  test "given invalid token to validate returns an error" do
    assert {:error, _} = Authenticator.validate_token("Some invalid token")
  end
end
