defmodule JarvisWeb.ListLive.Show do
  use JarvisWeb, :live_view

  alias Jarvis.Shopping

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        List {@list.id}
        <:subtitle>This is a list record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/shopping_lists"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/shopping_lists/#{@list}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit list
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@list.title}</:item>
        <:item title="Status">{@list.status}</:item>
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
end
