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
          <!-- Back button -->
          <.button navigate={~p"/shopping_lists"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <!-- Delete button -->
          <.button
            :if={@list.status != :deleted}
            variant="warning"
            disabled={@list.status == :done}
            onclick="confirm_delete.showModal()"
          >
            <.icon name="hero-trash" />
          </.button>
          <!-- Edit button -->
          <.button :if={@list.status == :deleted} variant="primary" phx-click="undo_delete">
            Undo delete
          </.button>
          <!-- Edit button -->
          <.button
            :if={@list.status != :deleted}
            variant="primary"
            disabled={@list.status == :done}
            navigate={~p"/shopping_lists/#{@list}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" />
          </.button>
          <!-- Done toggle -->
          <div :if={@list.status != :deleted} class="inline-block align-middle">
            <label class="label">
              <input
                type="checkbox"
                checked={@list.status == :done}
                class="toggle toggle-xl"
                phx-click="toggle_done"
              /> Done
            </label>
          </div>
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
        <:item title="Purchase at">{format_date(@list.purchase_at)}</:item>
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
    change_list_status(socket, "deleted")
  end

  def handle_event("undo_delete", _params, socket) do
    change_list_status(socket, "open")
  end

  def handle_event("mark_done", _params, socket) do
    change_list_status(socket, "done")
  end

  def handle_event("undo_done", _params, socket) do
    change_list_status(socket, "open")
  end

  def handle_event("toggle_done", _params, socket) do
    new_status = if socket.assigns.list.status == :done, do: "open", else: "done"
    change_list_status(socket, new_status)
  end

  defp change_list_status(socket, status) do
    {:ok, _} = socket.assigns.list |> Shopping.update_list(%{"status" => status})

    {:noreply, assign(socket, :list, Shopping.get_list!(socket.assigns.list.id))}
  end

  defp format_date(date), do: Calendar.strftime(date, "%d.%m.%Y")
end
