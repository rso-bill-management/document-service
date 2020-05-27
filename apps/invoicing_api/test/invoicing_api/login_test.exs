defmodule InvoicingSystem.API.LoginControllerTest do
  use ExUnitFixtures
  use InvoicingSystem.API.ConnCase
  use InvoicingSystem.DB.TestHelpers.DB
  alias InvoicingSystem.API.TestHelpers.Database, as: DbHelper

  deffixture init_users(), scope: :module, autouse: true do
    InvoicingSystem.TestHelpers.Users.init_users()
  end

  deffixture system(init_users), autouse: true do
    DbHelper.init_db(init_users)

    {:ok, _} = Application.ensure_all_started(:invoicing_iam)

    on_exit(fn ->
      Application.stop(:invoicing_iam)
    end)

    # application is started just once and there is no need to clean state between tests
    {:ok, _} = Application.ensure_all_started(:invoicing_api)
    :ok
  end

  describe "authenticate at /login" do
    test "with valid data returns status 200", %{conn: conn, init_users: [{uuid, _user} | _]} do
      resp =
        conn
        |> post("/login", username: "user1", password: "qwerty")
        |> json_response(:ok)

      assert %{
               "user_id" => ^uuid,
               "username" => "user1",
               "name" => "John",
               "surname" => "Smith",
               "token" => _
             } = resp
    end

    test "and reuse token to authenticate at /status endpoint", %{conn: conn} do
      %{"token" => token} =
        conn
        |> post("/login", username: "user1", password: "qwerty")
        |> json_response(:ok)

      conn
      |> get("/status")
      |> json_response(:unauthorized)

      conn
      |> put_req_header("authorization", token)
      |> get("/status")
      |> json_response(:ok)
    end

    test "and refreshes token", %{conn: conn} do
      %{"token" => token} =
        conn
        |> post("/login", username: "user1", password: "qwerty")
        |> json_response(:ok)

      # refresh token
      response =
        conn
        |> put_req_header("authorization", token)
        |> get("/status")

      json_response(response, :ok)
      [updated_token] = get_resp_header(response, "authorization")

      assert updated_token != token

      # reuse token
      build_conn()
      |> put_req_header("authorization", updated_token)
      |> get("/status")
      |> json_response(:ok)
    end
  end

  test "send POST /login with invalid login data should return bad request status", %{conn: conn} do
    conn
    |> post("/login", username: "john", password: "snow")
    |> json_response(:bad_request)
  end

  test "received token should be able to authenticate user in some other request", %{conn: conn} do
    resp =
      conn
      |> post("/login", username: "root", password: "password")
      |> json_response(:ok)

    conn
    |> put_req_header("authorization", resp["token"])
    |> get("/status")
    |> json_response(:ok)
  end

  test "should not allow users without valid token to access the system", %{conn: conn} do
    conn
    |> get("/status")
    |> json_response(:unauthorized)
  end
end
