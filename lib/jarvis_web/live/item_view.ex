defmodule JarvisWeb.ItemLive do
  use Phoenix.LiveView
  alias JarvisWeb.ItemView

  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.Item

  @doc """
  Will be call first for new connections
  """
  def mount(%{path_params: %{"id" => shopping_list_id}}, socket) do

    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    socket =  socket
              |> assign(%{changeset: ShoppingLists.change_item(%Item{})})
              |> assign(:shopping_list, shopping_list)
              |> assign(items: items)
    {:ok, socket}
  end

  @doc """
  Renders the static HTML after mounting the session.
  """
  def render(assigns) do
    ItemView.render("index.html", assigns)
  end

  def handle_event("save",
                  %{"item" => item},
                  %{assigns: %{shopping_list: shopping_list}} = socket) do

    case  ShoppingLists.create_item(item, shopping_list) do
      {:ok, _} ->
        items = ShoppingLists.list_items_by_shopping_list(shopping_list)
        {
          :noreply,
          socket
          |> put_flash(:info, "item created")
          |> assign(changeset: ShoppingLists.change_item(%Item{}))
          |> assign(items: items)
        }
      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :noreply,
          socket
          |> assign(changeset: changeset)
        }
    end
  end

  def handle_event("delete", _, socket) do
    {:noreply, socket}
  end
end
