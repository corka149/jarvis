defmodule JarvisWeb.ShoppingListApiController do
  use JarvisWeb, :controller

  alias Jarvis.ShoppingListsRepo

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index(conn, _params) do
    shopping_lists =
      conn.assigns.user
      |> ShoppingListsRepo.list_open_shoppinglists()
      |> ShoppingListsRepo.with_products()

    render(conn, "index.json", shopping_lists_api: shopping_lists)
  end
end
