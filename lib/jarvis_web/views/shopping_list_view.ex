defmodule JarvisWeb.ShoppingListView do
  @moduledoc """
  This view represents all possible response structures.
  """
  use JarvisWeb, :view

  alias JarvisWeb.ShoppingListView

  def render("index.json", %{shopping_lists: shopping_lists}) do
    render_many(shopping_lists, ShoppingListView, "show.json")
  end

  def render("show.json", %{shopping_list: shopping_list}) do
    %{
      id: shopping_list.id,
      done: shopping_list.done,
      planned_for: shopping_list.planned_for,
      creator: shopping_list.creator,
    }
  end

  def render("error.json", %{error: reason}) do
    %{
      scope: "shoppinglists",
      error: reason
    }
  end
end
