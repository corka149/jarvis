defmodule JarvisWeb.ShoppingListView do
  @moduledoc """
  This view represents all possible response structures.
  """
  use JarvisWeb, :view

  alias JarvisWeb.ShoppingListView

  def render("index.json", %{shoppinglists: shoppinglists}) do
    render_many(shoppinglists, ShoppingListView, "show.json")
  end

  def render("show.json", %{shoppinglist: shoppinglist}) do
    %{
      id: shoppinglist.id,
      done: shoppinglist.done,
      planned_for: shoppinglist.planned_for,
      creator: shoppinglist.creator,
    }
  end

  def render("error.json", %{error: reason}) do
    %{
      scope: "shoppinglists",
      error: reason
    }
  end
end
