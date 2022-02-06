defmodule JarvisWeb.ItemApiController do
  use JarvisWeb, :controller

  alias Jarvis.Inventory
  alias Jarvis.Inventory.Item

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index_html(conn, _params) do
    render(conn, "index.html")
  end

  def index(conn, _params) do
    items = Inventory.list_items()
    render(conn, "index.json", items_api: items)
  end

  def create(conn, %{"item" => item_params, "belongs_to" => belongs_to}) do
    place = Inventory.get_place!(belongs_to)

    with {:ok, %Item{} = item} <- Inventory.create_item(item_params, place) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.item_api_path(conn, :show, belongs_to, item))
      |> render("show.json", item_api: item)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Inventory.get_item!(id)
    render(conn, "show.json", item_api: item)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Inventory.get_item!(id)

    with {:ok, %Item{} = item} <- Inventory.update_item(item, item_params) do
      render(conn, "show.json", item_api: item)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Inventory.get_item!(id)

    with {:ok, %Item{}} <- Inventory.delete_item(item) do
      send_resp(conn, :no_content, "")
    end
  end
end
