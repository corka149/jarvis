defmodule Jarvis.ProductAuthorization do
  @moduledoc """
  Defines who can access products.
  """
  alias Jarvis.Repo.ShoppingLists
  alias Jarvis.ShoppingLists.ShoppingListAuthorization

  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(user, product_id) do
    %{shopping_list: shopping_list} = ShoppingLists.get_product!(product_id)
    ShoppingListAuthorization.is_allowed_to_cross?(user, shopping_list.id)
  end
end
