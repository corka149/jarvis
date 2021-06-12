defmodule JarvisWeb.ArtworkLive.FormComponent do
  use JarvisWeb, :live_component

  alias Jarvis.Accounts
  alias Jarvis.AnimalXing

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def update(%{artwork: artwork} = assigns, socket) do
    changeset = AnimalXing.change_artwork(artwork)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_groups(assigns.user)}
  end

  @impl true
  def handle_event("validate", %{"artwork" => artwork_params}, socket) do
    changeset =
      socket.assigns.artwork
      |> AnimalXing.change_artwork(artwork_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  # ===== PRIVATE =====

  def handle_event("save", %{"artwork" => artwork_params}, socket) do
    save_artwork(socket, socket.assigns.action, artwork_params)
  end

  defp save_artwork(socket, :edit, artwork_params) do
    case AnimalXing.update_artwork(socket.assigns.artwork, artwork_params) do
      {:ok, _artwork} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("animalxing", "Artwork updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_artwork(socket, :new, %{"belongs_to" => belongs_to} = artwork_params) do
    isle = AnimalXing.get_isle!(belongs_to)

    case AnimalXing.create_artwork(artwork_params, isle) do
      {:ok, _artwork} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("animalxing", "Artwork created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_groups(socket, user) do
    socket |> assign(:isles, isle_names_with_ids(user))
  end

  defp isle_names_with_ids(%Accounts.User{} = _user) do
    AnimalXing.list_isles()
    |> Enum.map(&{&1.name, &1.id})
  end
end
