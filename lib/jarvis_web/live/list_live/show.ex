defmodule JarvisWeb.ListLive.Show do
  use JarvisWeb, :live_view

  alias Jarvis.Shopping

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        List #{@list.id}
        <:actions>
          <.button navigate={~p"/shopping_lists"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button :if={@list.status == :open} variant="warning" onclick="confirm_delete.showModal()">
            <.icon name="hero-trash" />
          </.button>
          <.button
            :if={@list.status == :open}
            variant="primary"
            navigate={~p"/shopping_lists/#{@list}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" />
          </.button>
          <.button :if={@list.status == :deleted} variant="primary" phx-click="undo_delete">
            Undo delete
          </.button>
        </:actions>
      </.header>

      <dialog id="confirm_delete" class="modal">
        <div class="modal-box">
          <h3 class="text-lg font-bold">Delete List #{@list.id}</h3>
          <p class="py-4">Confirm deletion of this list?</p>
          <div class="modal-action">
            <form method="dialog">
              <.button variant="primary">Cancel</.button>
              <.button variant="warning" phx-click="delete">
                Delete
              </.button>
            </form>
          </div>
        </div>
      </dialog>

      <.list>
        <:item title="Title">{@list.title}</:item>
        <:item title="Purchase at">{@list.purchase_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show List")
     |> assign(:list, Shopping.get_list!(id))}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = socket.assigns.list |> Shopping.update_list(%{"status" => "deleted"})

    {:noreply, push_navigate(socket, to: ~p"/shopping_lists")}
  end

  def handle_event("undo_delete", _params, socket) do
    {:ok, _} = socket.assigns.list |> Shopping.update_list(%{"status" => "open"})

    {:noreply, assign(socket, :list, Shopping.get_list!(socket.assigns.list.id))}
  end
end
