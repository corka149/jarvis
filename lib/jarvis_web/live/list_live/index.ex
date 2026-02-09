defmodule JarvisWeb.ListLive.Index do
  use JarvisWeb, :live_view

  alias Jarvis.Shopping

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Shopping lists
        <:actions>
          <.button variant="primary" navigate={~p"/shopping_lists/new"}>
            <.icon name="hero-plus" /> New List
          </.button>
        </:actions>
      </.header>

      <.table
        id="shopping_lists"
        rows={@streams.shopping_lists}
        row_click={fn {_id, list} -> JS.navigate(~p"/shopping_lists/#{list}") end}
      >
        <:col :let={{_id, list}} label="Title">{list.title}</:col>
        <:col :let={{_id, list}} label="Purchase at">{list.purchase_at}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Shopping lists")
     |> stream(:shopping_lists, list_shopping_lists())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    list = Shopping.get_list!(id)
    {:ok, _} = Shopping.delete_list(list)

    {:noreply, stream_delete(socket, :shopping_lists, list)}
  end

  defp list_shopping_lists() do
    Shopping.list_shopping_lists()
  end
end
