defmodule JarvisWeb.IsleLive.Show do
  use JarvisWeb, :live_view

  alias Jarvis.Inventory

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @moduledoc """
  Live view for showing a single isle.
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
     |> assign(:isle, Inventory.get_isle!(id))}
  end

  defp page_title(:show), do: dgettext("inventory", "Show isle")

  # user_id is available but user is not needed here
  defp assign_user(socket, %{"user_id" => _user_id}) do
    socket
  end

  # No user there - not authenticated
  defp assign_user(socket, _) do
    redirect(socket, to: Routes.auth_path(socket, :signin))
  end
end
