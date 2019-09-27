defmodule JarvisWeb.Api.ShoppingListApiView do
  use JarvisWeb, :view

  alias JarvisWeb.Api.ItemApiView
  alias JarvisWeb.Api.ShoppingListApiView

  def render("index.json", %{shopping_lists: shopping_lists}) do
    render_many(shopping_lists, ShoppingListApiView, "show.json")
  end

  def render("show.json", %{shopping_list_api: shopping_list}) do
    %{
      planned_for: shopping_list.planned_for,
      belongs_to: shopping_list.usergroup.name,
      items: render_many(shopping_list.items, ItemApiView, "show.json")
    }
  end
end
