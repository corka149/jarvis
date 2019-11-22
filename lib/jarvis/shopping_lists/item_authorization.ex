defmodule Jarvis.ItemAuthorization do
  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(user, item_id) do
    %{shopping_list: shopping_list} = Jarvis.ShoppingLists.get_item!(item_id)
    Jarvis.ShoppingLists.ShoppingListAuthorization.is_allowed_to_cross?(user, shopping_list.id)
  end
end
