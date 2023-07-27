defmodule JarvisWeb.ProductApiView do
  @moduledoc """
  This view represents all possible response structure.
  """
  use JarvisWeb, :html

  def render("product.json", %{product_api: product}) do
    %{id: product.id, name: product.name, amount: product.amount}
  end
end
