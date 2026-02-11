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
          <.button variant="neutral" phx-click="show_all">
            <.icon name="hero-eye" />
          </.button>
          <.button variant="primary" navigate={~p"/shopping_lists/new"}>
            <.icon name="hero-plus" />
          </.button>
        </:actions>
      </.header>

      <.table
        id="shopping_lists"
        rows={@streams.shopping_lists}
        row_click={fn {_id, list} -> JS.navigate(~p"/shopping_lists/#{list}") end}
      >
        <:col :let={{_id, list}} label="Title">{list.title}</:col>
        <:col :let={{_id, list}} label="Purchase at">{format_date(list.purchase_at)}</:col>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Shopping lists")
     |> stream(:shopping_lists, list_open_shopping_lists())}
  end

  @impl true
  def handle_event("show_all", _params, socket) do
    show_all = not Map.get(socket.assigns, :show_all, false)

    lists = if show_all, do: list_shopping_lists(), else: list_open_shopping_lists()

    socket =
      socket
      |> stream(:shopping_lists, lists, reset: true)
      |> assign(:show_all, show_all)

    {:noreply, socket}
  end

  defp list_shopping_lists() do
    Shopping.list_shopping_lists()
  end

  defp list_open_shopping_lists() do
    Shopping.list_open_shopping_lists()
  end

  defp format_date(date), do: Calendar.strftime(date, "%d.%m.%Y")
end
