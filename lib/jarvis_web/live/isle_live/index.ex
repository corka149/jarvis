defmodule JarvisWeb.IsleLive.Index do
  use JarvisWeb, :live_view

  alias Jarvis.Accounts
  alias Jarvis.Inventory
  alias Jarvis.Inventory.Isle

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @moduledoc """
  Live view for listing isles.
  """

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_isles()
     |> assign_user(session)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("inventory", "Edit Isle"))
    |> assign(:isle, Inventory.get_isle!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("inventory", "New Isle"))
    |> assign(:isle, %Isle{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("inventory", "Listing Isles"))
    |> assign(:isle, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    isle = Inventory.get_isle!(id)
    {:ok, _} = Inventory.delete_isle(isle)

    {:noreply, assign(socket, :isles, list_isles())}
  end

  # ===== PRIVATE =====

  defp assign_isles(socket) do
    assign(socket, :isles, list_isles())
  end

  defp assign_user(socket, %{"user_id" => user_id}) do
    assign(socket, :user, Accounts.get_user!(user_id))
  end

  # No user there - not authenticated
  defp assign_user(socket, _) do
    redirect(socket, to: Routes.auth_path(socket, :signin))
  end

  defp list_isles do
    Inventory.list_isles()
  end
end
