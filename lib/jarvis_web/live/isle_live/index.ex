defmodule JarvisWeb.IsleLive.Index do
  use JarvisWeb, :live_view

  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Isle

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :isles, list_isles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Isle")
    |> assign(:isle, AnimalXing.get_isle!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Isle")
    |> assign(:isle, %Isle{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Isles")
    |> assign(:isle, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    isle = AnimalXing.get_isle!(id)
    {:ok, _} = AnimalXing.delete_isle(isle)

    {:noreply, assign(socket, :isles, list_isles())}
  end

  defp list_isles do
    AnimalXing.list_isles()
  end
end
