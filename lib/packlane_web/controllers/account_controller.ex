defmodule PacklaneWeb.AccountController do
  use PacklaneWeb, :controller

  alias Packlane.Banking
  alias Packlane.Banking.Account

  action_fallback PacklaneWeb.FallbackController

  def index(conn, _params) do
    banking_accounts = Banking.list_banking_accounts(conn.assigns.current_user.id)
    render(conn, "index.json", banking_accounts: banking_accounts)
  end

  def create(conn, %{"account" => account_params}) do
    attrs = Map.put(account_params, "user_id", conn.assigns.current_user.id)
    with {:ok, %Account{} = account} <- Banking.create_account(attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => id}) do
    account = Banking.get_account!(id)
    render(conn, "show.json", account: account)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Banking.get_account!(id)

    with {:ok, %Account{} = account} <- Banking.update_account(account, account_params) do
      render(conn, "show.json", account: account)
    end
  end

  def delete(conn, %{"id" => id}) do
    account = Banking.get_account!(id)

    with {:ok, %Account{}} <- Banking.delete_account(account) do
      send_resp(conn, :no_content, "")
    end
  end
end
