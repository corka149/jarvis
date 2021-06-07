defmodule JarvisWeb.ArtworkLive.Index do
  use JarvisWeb, :live_view

  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Artwork

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :artworks, list_artworks())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("animalxing", "Edit Artwork"))
    |> assign(:artwork, AnimalXing.get_artwork!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("animalxing", "New Artwork"))
    |> assign(:artwork, %Artwork{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("animalxing", "Listing Artworks"))
    |> assign(:artwork, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    artwork = AnimalXing.get_artwork!(id)
    {:ok, _} = AnimalXing.delete_artwork(artwork)

    {:noreply, assign(socket, :artworks, list_artworks())}
  end

  defp list_artworks do
    AnimalXing.list_artworks()
  end
end
