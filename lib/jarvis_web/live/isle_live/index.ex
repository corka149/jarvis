defmodule JarvisWeb.IsleLive.Index do
  use JarvisWeb, :live_view

  alias Jarvis.Accounts
  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Isle

  import JarvisWeb.Gettext, only: [dgettext: 2]

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_isles()
     |> assign_user(session)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("animalxing", "Edit Isle"))
    |> assign(:isle, AnimalXing.get_isle!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("animalxing", "New Isle"))
    |> assign(:isle, %Isle{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("animalxing", "Listing Isles"))
    |> assign(:isle, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    isle = AnimalXing.get_isle!(id)
    {:ok, _} = AnimalXing.delete_isle(isle)

    {:noreply, assign(socket, :isles, list_isles())}
  end

  # ===== PRIVATE =====

  defp assign_isles(socket) do
    assign(socket, :isles, list_isles())
  end

  defp assign_user(socket, session) do
    assign(socket, :user, session |> Map.get("user_id") |> Accounts.get_user!())
  end

  defp list_isles() do
    AnimalXing.list_isles()
  end
end
