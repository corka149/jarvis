defmodule JarvisWeb.ArtworkLive.FormComponent do
  use JarvisWeb, :live_component

  alias Jarvis.AnimalXing

  @impl true
  def update(%{artwork: artwork} = assigns, socket) do
    changeset = AnimalXing.change_artwork(artwork)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"artwork" => artwork_params}, socket) do
    changeset =
      socket.assigns.artwork
      |> AnimalXing.change_artwork(artwork_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"artwork" => artwork_params}, socket) do
    save_artwork(socket, socket.assigns.action, artwork_params)
  end

  defp save_artwork(socket, :edit, artwork_params) do
    case AnimalXing.update_artwork(socket.assigns.artwork, artwork_params) do
      {:ok, _artwork} ->
        {:noreply,
         socket
         |> put_flash(:info, "Artwork updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_artwork(socket, :new, artwork_params) do
    case AnimalXing.create_artwork(artwork_params) do
      {:ok, _artwork} ->
        {:noreply,
         socket
         |> put_flash(:info, "Artwork created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
