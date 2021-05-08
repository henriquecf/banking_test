defmodule PacklaneWeb.AccountControllerTest do
  use PacklaneWeb.ConnCase

  import Packlane.AccountsFixtures
  import Packlane.BankingFixtures

  alias Packlane.Banking

  @create_attrs %{
    name: "some name",
    type: "checking"
  }
  @invalid_attrs %{balance: nil, name: nil, type: nil}

  def fixture(:account, user) do
    create_attrs = Map.put(@create_attrs, :user_id, user.id)
    {:ok, account} = Banking.create_account(create_attrs)
    account
  end

  setup :register_and_log_in_user

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all banking_accounts", %{conn: conn} do
      conn = get(conn, Routes.account_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.account_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "balance" => "0",
               "name" => "some name",
               "type" => "checking"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show" do
    test "does not allow to access other users account", %{conn: conn} do
      other_user = user_fixture()
      other_account = account_fixture(%{user_id: other_user.id})
      conn = get(conn, Routes.account_path(conn, :show, other_account.id))
      assert json_response(conn, 404)
    end
  end
end
