defmodule JarvisWeb.ShoppingListApiView do
  @moduledoc """
  This view represents all possible response structure.
  """
  use JarvisWeb, :html
  alias JarvisWeb.ProductApiView
  alias JarvisWeb.ShoppingListApiView
  alias JarvisWeb.UserGroupApiView

  def render("index.json", %{shopping_lists_api: shopping_lists}) do
    %{data: render(shopping_lists, ShoppingListApiView, "shopping_list.json")}
  end

  def render("show.json", %{shopping_list_api: shopping_list}) do
    %{data: render_one(shopping_list, ShoppingListApiView, "shopping_list.json")}
  end

  def render("shopping_list.json", %{shopping_list_api: shopping_list}) do
    products = render_many(shopping_list.products, ProductApiView, "product.json")
    group = render_one(shopping_list.usergroup, UserGroupApiView, "user_group.json")

    %{
      id: shopping_list.id,
      planned_for: shopping_list.planned_for,
      products: products,
      belongs_to: group
    }
  end
end
