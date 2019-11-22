defmodule JarvisWeb.CategoryView do
  use JarvisWeb, :view
  alias JarvisWeb.CategoryView

  def render("index.json", %{categories: categories}) do
    render_many(categories, CategoryView, "category.json")
  end

  def render("show.json", %{category: category}) do
    render_one(category, CategoryView, "category.json")
  end

  def render("category.json", %{category: category}) do
    %{id: category.id, name: category.name}
  end
end
