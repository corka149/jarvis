defmodule JarvisWeb.Api.ItemApiView do
  use JarvisWeb, :view

  def render("show.json", %{item_api: item}) do
    %{
      name: item.name,
      amount: item.amount
    }
  end

end
