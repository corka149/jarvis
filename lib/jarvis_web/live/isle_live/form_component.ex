defmodule JarvisWeb.IsleLive.FormComponent do
  use JarvisWeb, :live_component

  alias Jarvis.AnimalXing

  @impl true
  def update(%{isle: isle} = assigns, socket) do
    changeset = AnimalXing.change_isle(isle)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
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

  defp save_isle(socket, :edit, isle_params) do
    case AnimalXing.update_isle(socket.assigns.isle, isle_params) do
      {:ok, _isle} ->
        {:noreply,
         socket
         |> put_flash(:info, "Isle updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_isle(socket, :new, isle_params) do
    case AnimalXing.create_isle(isle_params) do
      {:ok, _isle} ->
        {:noreply,
         socket
         |> put_flash(:info, "Isle created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
