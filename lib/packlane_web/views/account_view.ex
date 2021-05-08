defmodule PacklaneWeb.AccountView do
  use PacklaneWeb, :view
  alias PacklaneWeb.AccountView

  def render("index.json", %{banking_accounts: banking_accounts}) do
    %{data: render_many(banking_accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{id: account.id,
      name: account.name,
      type: account.type,
      balance: account.balance}
  end
end
