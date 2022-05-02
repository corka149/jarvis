defmodule JarvisWeb.ShoppingListApiController do
  use JarvisWeb, :controller

  alias Jarvis.ShoppingListsRepo

  action_fallback JarvisWeb.FallbackController

  def index(conn, _params) do
    shopping_lists = ShoppingListsRepo.list_shoppinglists()

    render(conn, "index.json", shopping_lists_api: shopping_lists)
  end
end
