defmodule JarvisWeb.ItemLive.FormComponent do
  @moduledoc """
  Live view for item form component.
  """

  use JarvisWeb, :live_component

  alias Jarvis.Accounts
  alias Jarvis.Inventory

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def update(%{item: item} = assigns, socket) do
    changeset = Inventory.change_item(item)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_groups(assigns.user)}
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Inventory.change_item(item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.action, item_params)
  end

  # ===== PRIVATE =====

  defp save_item(socket, :edit, item_params) do
    case Inventory.update_item(socket.assigns.item, item_params) do
      {:ok, _item} ->
        :ok = broadcast_change()

        {:noreply,
         socket
         |> put_flash(:info, dgettext("inventory", "Item updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_item(socket, :new, %{"belongs_to" => belongs_to} = item_params) do
    place = Inventory.get_place!(belongs_to)

    case Inventory.create_item(item_params, place) do
      {:ok, _item} ->
        :ok = broadcast_change()

        {:noreply,
         socket
         |> put_flash(:info, dgettext("inventory", "Item created successfully"))
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
    Phoenix.PubSub.broadcast(Jarvis.PubSub, "items", :items_changed)
  end
end
