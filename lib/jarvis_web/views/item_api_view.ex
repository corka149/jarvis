defmodule JarvisWeb.ItemApiView do
  use JarvisWeb, :view
  alias JarvisWeb.ItemApiView

  def render("index.json", %{items_api: items}) do
    %{data: render_many(items, ItemApiView, "item.json")}
  end

  def render("show.json", %{item_api: item}) do
    %{data: render_one(item, ItemApiView, "item.json")}
  end

  def render("item.json", %{item_api: item}) do
    %{id: item.id, name: item.name}
  end
end
