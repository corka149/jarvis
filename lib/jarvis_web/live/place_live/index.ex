defmodule JarvisWeb.PlaceLive.Index do
  use JarvisWeb, :live_view

  alias Jarvis.AccountsRepo
  alias Jarvis.Inventories.Place
  alias Jarvis.InventoriesRepo
  import(JarvisWeb.Gettext, only: [dgettext: 2])

  @moduledoc """
  Live view for listing places.
  """

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_places()
     |> assign_user(session)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("inventory", "Edit Place"))
    |> assign(:place, InventoriesRepo.get_place!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("inventory", "New Place"))
    |> assign(:place, %Place{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("inventory", "Listing Places"))
    |> assign(:place, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    place = InventoriesRepo.get_place!(id)
    {:ok, _} = InventoriesRepo.delete_place(place)

    {:noreply, assign(socket, :places, list_places())}
  end

  # ===== PRIVATE =====

  defp assign_places(socket) do
    assign(socket, :places, list_places())
  end

  defp assign_user(socket, %{"user_id" => user_id}) do
    user = AccountsRepo.get_user!(user_id)
    Gettext.put_locale(user.default_language)
    assign(socket, :user, user)
  end

  # No user there - not authenticated
  defp assign_user(socket, _) do
    redirect(socket, to: Routes.auth_path(socket, :signin))
  end

  defp list_places do
    InventoriesRepo.list_places()
  end
end
