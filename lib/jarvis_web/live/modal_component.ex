defmodule JarvisWeb.ModalComponent do
  use JarvisWeb, :live_component

  @moduledoc """
  Modal component for live views.
  """

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target={"##{@id}"}
      phx-page-loading>

      <div class="phx-modal-content">
        <%= cancel_button @return_to %>
        <%= live_component @component, @opts %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end
end
