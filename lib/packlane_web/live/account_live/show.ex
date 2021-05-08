defmodule PacklaneWeb.AccountLive.Show do
  use PacklaneWeb, :live_view

  alias Packlane.Banking

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_current_user(socket, session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:account, Banking.get_account!(socket.assigns.current_user.id, id))}
  end

  defp page_title(:show), do: "Show Account"
  defp page_title(:edit), do: "Edit Account"
end
