defmodule PacklaneWeb.TransactionLive.FormComponent do
  use PacklaneWeb, :live_component

  alias Packlane.Banking

  @impl true
  def update(%{accounts: accounts, transaction: transaction} = assigns, socket) do
    changeset = Banking.change_transaction(transaction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:accounts, accounts)
     |> assign(:main_error, nil)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Banking.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset, main_error: nil)}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :new_transaction, transaction_params) do
    case Banking.create_transaction(transaction_params) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, error} when is_binary(error) ->
        {:noreply, assign(socket, main_error: error)}
    end
  end
end
