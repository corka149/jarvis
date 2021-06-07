defmodule JarvisWeb.ArtworkLive.Show do
  use JarvisWeb, :live_view

  alias Jarvis.AnimalXing

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:artwork, AnimalXing.get_artwork!(id))}
  end

  defp page_title(:show), do: dgettext("animalxing", "Show Artwork")
  defp page_title(:edit), do: dgettext("animalxing", "Edit Artwork")
end
