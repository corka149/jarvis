defmodule JarvisWeb.ArtworkLive.FormComponent do
  @moduledoc """
  Live view for artwork form component.
  """

  use JarvisWeb, :live_component

  alias Jarvis.Accounts
  alias Jarvis.Inventory

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def update(%{artwork: artwork} = assigns, socket) do
    changeset = Inventory.change_artwork(artwork)

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
      |> Inventory.change_artwork(artwork_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"artwork" => artwork_params}, socket) do
    save_artwork(socket, socket.assigns.action, artwork_params)
  end

  # ===== PRIVATE =====

  defp save_artwork(socket, :edit, artwork_params) do
    case Inventory.update_artwork(socket.assigns.artwork, artwork_params) do
      {:ok, _artwork} ->
        :ok = broadcast_change()

        {:noreply,
         socket
         |> put_flash(:info, dgettext("inventory", "Artwork updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_artwork(socket, :new, %{"belongs_to" => belongs_to} = artwork_params) do
    place = Inventory.get_place!(belongs_to)

    case Inventory.create_artwork(artwork_params, place) do
      {:ok, _artwork} ->
        :ok = broadcast_change()

        {:noreply,
         socket
         |> put_flash(:info, dgettext("inventory", "Artwork created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_groups(socket, user) do
    socket |> assign(:places, place_names_with_ids(user))
  end

  defp place_names_with_ids(%Accounts.User{} = _user) do
    Inventory.list_places()
    |> Enum.map(&{&1.name, &1.id})
  end

  defp broadcast_change do
    Phoenix.PubSub.broadcast(Jarvis.PubSub, "artworks", :artworks_changed)
  end
end
