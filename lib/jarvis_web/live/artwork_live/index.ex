defmodule JarvisWeb.ArtworkLive.Index do
  @moduledoc """
  Live view for listing artworks.
  """

  use JarvisWeb, :live_view

  alias Jarvis.Accounts
  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Artwork

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket |> assign_artworks |> assign_user(session)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    :ok = Phoenix.PubSub.subscribe(Jarvis.PubSub, "artworks")

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    artwork = AnimalXing.get_artwork!(id)
    {:ok, _} = AnimalXing.delete_artwork(artwork)

    :ok = broadcast_change()

    {:noreply, assign(socket, :artworks, list_artworks())}
  end

  @impl true
  def handle_info(message, socket) do
    case message do
      :artworks_changed -> {:noreply, socket |> assign_artworks}
      _ -> {:noreply, socket}
    end
  end

  # ===== PRIVATE =====

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

  defp assign_artworks(socket) do
    assign(socket, :artworks, list_artworks())
  end

  defp assign_user(socket, session) do
    assign(socket, :user, session |> Map.get("user_id") |> Accounts.get_user!())
  end

  defp list_artworks do
    AnimalXing.list_artworks()
  end

  defp broadcast_change do
    Phoenix.PubSub.broadcast(Jarvis.PubSub, "artworks", :artworks_changed)
  end
end
