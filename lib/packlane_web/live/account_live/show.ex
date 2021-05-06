defmodule PacklaneWeb.AccountLive.Show do
  use PacklaneWeb, :live_view

  alias Packlane.Banking

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:account, Banking.get_account!(id))}
  end

  defp page_title(:show), do: "Show Account"
  defp page_title(:edit), do: "Edit Account"
end
