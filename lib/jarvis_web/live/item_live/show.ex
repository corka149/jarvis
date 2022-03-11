defmodule JarvisWeb.ItemLive.Show do
  @moduledoc """
  Live view for showing an item.
  """

  use JarvisWeb, :live_view

  alias Jarvis.AccountsRepo
  alias Jarvis.InventoryRepo

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket |> assign_user(session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, InventoryRepo.get_item!(id))}
  end

  # ===== PRIVATE =====
  defp page_title(:show), do: dgettext("inventory", "Show item")
  defp page_title(:edit), do: dgettext("inventory", "Edit Item")

  defp assign_user(socket, %{"user_id" => user_id}) do
    assign(socket, :user, AccountsRepo.get_user!(user_id))
  end

  # No user there - not authenticated
  defp assign_user(socket, _) do
    redirect(socket, to: Routes.auth_path(socket, :signin))
  end
end
