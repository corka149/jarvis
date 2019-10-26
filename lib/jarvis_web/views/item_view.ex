defmodule JarvisWeb.ItemView do
  use JarvisWeb, :view

  alias JarvisWeb.ItemView

  def render("index.json", %{items: items}) do
    render_many(items, ItemView, "show.json")
  end

  def render("show.json", %{item: item}) do
    %{
      id: item.id,
      amount: item.amount,
      name: item.name
    }
  end
end
