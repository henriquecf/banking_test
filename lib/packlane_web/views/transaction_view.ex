defmodule PacklaneWeb.TransactionView do
  use PacklaneWeb, :view
  alias PacklaneWeb.TransactionView

  def render("index.json", %{banking_transactions: banking_transactions}) do
    %{data: render_many(banking_transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{id: transaction.id,
      type: transaction.type,
      from_id: transaction.from_id,
      to_id: transaction.to_id,
      amount: transaction.amount}
  end
end
