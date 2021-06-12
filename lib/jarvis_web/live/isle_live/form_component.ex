defmodule JarvisWeb.IsleLive.FormComponent do
  use JarvisWeb, :live_component

  alias Jarvis.Accounts
  alias Jarvis.AnimalXing

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @moduledoc """
  Live view for editing or creating isles.
  """

  @impl true
  def update(%{isle: isle} = assigns, socket) do
    changeset = AnimalXing.change_isle(isle)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_isles(assigns.user)}
  end

  @impl true
  def handle_event("validate", %{"isle" => isle_params}, socket) do
    changeset =
      socket.assigns.isle
      |> AnimalXing.change_isle(isle_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"isle" => isle_params}, socket) do
    save_isle(socket, socket.assigns.action, isle_params)
  end

  # ===== PRIVATE =====

  defp save_isle(socket, :edit, isle_params) do
    case AnimalXing.update_isle(socket.assigns.isle, isle_params) do
      {:ok, _isle} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("animalxing", "Isle updated successfully")
         )
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_isle(socket, :new, %{"belongs_to" => belongs_to} = isle_params) do
    user_group = Accounts.get_user_group!(belongs_to)

    case AnimalXing.create_isle(isle_params, user_group) do
      {:ok, _isle} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("animalxing", "Isle created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_isles(socket, user) do
    socket |> assign(:user_groups, group_names_with_ids(user))
  end

  defp group_names_with_ids(%Accounts.User{} = user) do
    Accounts.list_usergroups_by_membership_or_owner(user)
    |> Enum.map(&{&1.name, &1.id})
  end
end
