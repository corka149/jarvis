
defmodule JarvisWeb.ItemController do
  use JarvisWeb, :controller

  alias Jarvis.ShoppingLists

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuth

  def index(conn, %{"shopping_list_id" => shopping_list_id}) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    render(conn, "index.json", items: items)
  end

  def show(conn, %{"id" => id}) do
    item = ShoppingLists.get_item!(id)
    render(conn, "show.json", item: item)
  end

  def create(conn, %{"shopping_list_id" => shopping_list_id, "item" => items_params}) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    with {:ok, item} <-
           ShoppingLists.create_item(items_params, shopping_list) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.item_path(conn, :show, shopping_list_id, item))
      |> render("show.json", item: item)
    end
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = ShoppingLists.get_item!(id)
    {_, item_params} = Map.pop(item_params, :belongs_to)

    with {:ok, item} <-
           ShoppingLists.update_item(item, item_params) do
      render(conn, "show.json", item: item)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = ShoppingLists.get_item!(id)
    {:ok, _item} = ShoppingLists.delete_item(item)

    send_resp(conn, :no_content, "")
  end
end
