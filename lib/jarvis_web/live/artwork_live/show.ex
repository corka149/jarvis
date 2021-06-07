defmodule JarvisWeb.ArtworkLive.Show do
  use JarvisWeb, :live_view

  alias Jarvis.Accounts
  alias Jarvis.AnimalXing

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
     |> assign(:artwork, AnimalXing.get_artwork!(id))}
  end

  # ===== PRIVATE =====
  defp page_title(:show), do: dgettext("animalxing", "Show Artwork")
  defp page_title(:edit), do: dgettext("animalxing", "Edit Artwork")

  defp assign_user(socket, session) do
    assign(socket, :user, session |> Map.get("user_id") |> Accounts.get_user!())
  end
end
