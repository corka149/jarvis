defmodule JarvisWeb.Api.ShoppingListApiController do
  use JarvisWeb, :controller

  alias Jarvis.ShoppingLists

  action_fallback JarvisWeb.FallbackController

  def list_open_lists(conn, _params) do
    open_lists = ShoppingLists.list_open_shoppinglists

    conn
    |> put_status(:ok)
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> render("index.json", shopping_lists: open_lists)
  end

end
