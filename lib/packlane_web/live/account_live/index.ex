defmodule PacklaneWeb.AccountLive.Index do
  use PacklaneWeb, :live_view

  alias Packlane.Banking
  alias Packlane.Banking.{Account, Transaction}

  @impl true
  def mount(_params, session, socket) do
    socket = assign_current_user(socket, session)
    {:ok, assign(socket, :banking_accounts, list_banking_accounts(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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

  defp apply_action(socket, :new_transaction, _params) do
    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, %Transaction{})
  end

  defp list_banking_accounts(user) do
    Banking.list_banking_accounts(user.id)
  end
end
