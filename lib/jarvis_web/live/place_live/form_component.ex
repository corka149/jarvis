defmodule JarvisWeb.PlaceLive.FormComponent do
  use JarvisWeb, :live_component

  alias Jarvis.Accounts.User
  alias Jarvis.Inventory
  alias Jarvis.Repo.Accounts

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @moduledoc """
  Live view for editing or creating places.
  """

  @impl true
  def update(%{place: place} = assigns, socket) do
    changeset = Inventory.change_place(place)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_groups(assigns.user)}
  end

  @impl true
  def handle_event("validate", %{"place" => place_params}, socket) do
    changeset =
      socket.assigns.place
      |> Inventory.change_place(place_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"place" => place_params}, socket) do
    save_place(socket, socket.assigns.action, place_params)
  end

  # ===== PRIVATE =====

  defp save_place(socket, :edit, place_params) do
    case Inventory.update_place(socket.assigns.place, place_params) do
      {:ok, _place} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("inventory", "Place updated successfully")
         )
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_place(socket, :new, %{"belongs_to" => belongs_to} = place_params) do
    user_group = Accounts.get_user_group!(belongs_to)

    case Inventory.create_place(place_params, user_group) do
      {:ok, _place} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("inventory", "Place created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_groups(socket, user) do
    socket |> assign(:user_groups, group_names_with_ids(user))
  end

  defp group_names_with_ids(%User{} = user) do
    Accounts.list_usergroups_by_membership_or_owner(user)
    |> Enum.map(&{&1.name, &1.id})
  end
end
