defmodule JarvisWeb.ShoppingListApiView do
  @moduledoc """
  This view represents all possible response structure.
  """
  use JarvisWeb, :view
  alias JarvisWeb.ProductApiView
  alias JarvisWeb.ShoppingListApiView

  def render("index.json", %{shopping_lists_api: shopping_lists}) do
    %{data: render_many(shopping_lists, ShoppingListApiView, "shopping_list.json")}
  end

  def render("show.json", %{shopping_list_api: shopping_list}) do
    %{data: render_one(shopping_list, ShoppingListApiView, "shopping_list.json")}
  end

  def render("shopping_list.json", %{shopping_list_api: shopping_list}) do
    products = render_many(shopping_list.products, ProductApiView, "product.json")

    %{id: shopping_list.id, planned_for: shopping_list.planned_for, products: products}
  end
end
