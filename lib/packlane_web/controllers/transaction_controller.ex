defmodule PacklaneWeb.TransactionController do
  use PacklaneWeb, :controller

  alias Packlane.Banking
  alias Packlane.Banking.Transaction

  action_fallback PacklaneWeb.FallbackController

  def index(conn, _params) do
    banking_transactions = Banking.list_banking_transactions(conn.assigns.current_user.id)
    render(conn, "index.json", banking_transactions: banking_transactions)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, %Transaction{} = transaction} <- Banking.create_transaction(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Banking.get_transaction!(id)
    render(conn, "show.json", transaction: transaction)
  end
end
