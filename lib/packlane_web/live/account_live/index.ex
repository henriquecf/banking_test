defmodule PacklaneWeb.AccountLive.Index do
  use PacklaneWeb, :live_view

  alias Packlane.{Banking, Accounts}
  alias Packlane.Banking.Account

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    {:ok, assign(socket, banking_accounts: list_banking_accounts(), current_user: user)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Account")
    |> assign(:account, Banking.get_account!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Account")
    |> assign(:account, %Account{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Banking accounts")
    |> assign(:account, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Banking.get_account!(id)
    {:ok, _} = Banking.delete_account(account)

    {:noreply, assign(socket, :banking_accounts, list_banking_accounts())}
  end

  defp list_banking_accounts do
    Banking.list_banking_accounts()
  end
end
