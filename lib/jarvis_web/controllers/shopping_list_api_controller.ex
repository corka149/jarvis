defmodule JarvisWeb.ShoppingListApiController do
  use JarvisWeb, :controller

  alias Jarvis.ShoppingListsRepo

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index(conn, _params) do
    shopping_lists = ShoppingListsRepo.list_shoppinglists_for_user(conn.assigns.user)

    render(conn, "index.json", shopping_lists_api: shopping_lists)
  end
end
