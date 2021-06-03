defmodule JarvisWeb.IsleLive.Show do
  use JarvisWeb, :live_view

  alias Jarvis.AnimalXing

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:isle, AnimalXing.get_isle!(id))}
  end

  defp page_title(:show), do: "Show Isle"
  defp page_title(:edit), do: "Edit Isle"
end
