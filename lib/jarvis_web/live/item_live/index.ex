defmodule JarvisWeb.ItemLive.Index do
  @moduledoc """
  Live view for listing items.
  """

  use JarvisWeb, :live_view

  alias Jarvis.Accounts
  alias Jarvis.Inventory
  alias Jarvis.Inventory.Item

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket |> assign_items |> assign_user(session)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    :ok = Phoenix.PubSub.subscribe(Jarvis.PubSub, "items")

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Inventory.get_item!(id)
    {:ok, _} = Inventory.delete_item(item)

    :ok = broadcast_change()

    {:noreply, assign(socket, :items, list_items())}
  end

  @impl true
  def handle_info(message, socket) do
    case message do
      :items_changed -> {:noreply, socket |> assign_items}
      _ -> {:noreply, socket}
    end
  end

  # ===== PRIVATE =====

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("inventory", "Edit Item"))
    |> assign(:item, Inventory.get_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("inventory", "New Item"))
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("inventory", "Listing Items"))
    |> assign(:item, nil)
  end

  defp assign_items(socket) do
    assign(socket, :items, list_items())
  end

  defp assign_user(socket, %{"user_id" => user_id}) do
    assign(socket, :user, Accounts.get_user!(user_id))
  end

  # No user there - not authenticated
  defp assign_user(socket, _) do
    redirect(socket, to: Routes.auth_path(socket, :signin))
  end

  defp list_items do
    Inventory.list_items()
  end

  defp broadcast_change do
    Phoenix.PubSub.broadcast(Jarvis.PubSub, "items", :items_changed)
  end
end
