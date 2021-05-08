defmodule PacklaneWeb.TransactionControllerTest do
  use PacklaneWeb.ConnCase

  import Packlane.BankingFixtures
  import Packlane.AccountsFixtures

  alias Packlane.Banking

  @create_attrs %{
    amount: "100",
    type: "deposit"
  }
  @invalid_attrs %{amount: "100", type: "transfer"}

  def fixture(:transaction) do
    {:ok, transaction} = Banking.create_transaction(@create_attrs)
    transaction
  end

  setup :register_and_log_in_user

  setup %{conn: conn, user: user} do
    account = account_fixture(%{user_id: user.id})
    {:ok, conn: put_req_header(conn, "accept", "application/json"), account: account}
  end

  describe "index" do
    test "lists all banking_transactions", %{conn: conn} do
      conn = get(conn, Routes.transaction_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn, account: account} do
      account_id = account.id
      create_attrs = Map.put(@create_attrs, :to_id, account.id)
      conn = post(conn, Routes.transaction_path(conn, :create), transaction: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.transaction_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "amount" => "100",
               "from_id" => nil,
               "to_id" => ^account_id,
               "type" => "deposit"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.transaction_path(conn, :create), transaction: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show" do
    test "does not allow to access other users transaction", %{conn: conn} do
      other_user = user_fixture()
      other_account = account_fixture(%{user_id: other_user.id})
      other_transaction = transaction_fixture(%{to_id: other_account.id})
      conn = get(conn, Routes.transaction_path(conn, :show, other_transaction.id))
      assert json_response(conn, 404)
    end
  end
end
