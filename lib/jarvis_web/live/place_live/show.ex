defmodule JarvisWeb.PlaceLive.Show do
  use JarvisWeb, :live_view

  alias Jarvis.InventoriesRepo
  import JarvisWeb.Gettext, only: [dgettext: 2]

  @moduledoc """
  Live view for showing a single place.
  """

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket |> assign_user(session)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:place, InventoriesRepo.get_place!(id))}
  end

  defp page_title(:show), do: dgettext("inventory", "Show place")

  # user_id is available but user is not needed here
  defp assign_user(socket, %{"user_id" => _user_id}) do
    socket
  end

  # No user there - not authenticated
  defp assign_user(socket, _) do
    redirect(socket, to: Routes.auth_path(socket, :signin))
  end
end
