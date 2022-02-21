defmodule Jarvis.ShoppingLists.ShoppingListAuthorization do
  @moduledoc """
  Defines who can access shopping lists.
  """
  alias Jarvis.Repo.ShoppingLists
  alias Jarvis.ShoppingLists.ShoppingList

  @behaviour JarvisWeb.AuthorizationBorder

  @impl JarvisWeb.AuthorizationBorder
  def is_allowed_to_cross?(user, shopping_list_id) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)

    is_group_member(user.usergroups, shopping_list) or
      is_group_member(user.member_of, shopping_list)
  end

  defp is_group_member(user_groups, %ShoppingList{} = shopping_list) do
    Enum.any?(user_groups, fn group -> group.id == shopping_list.usergroup.id end)
  end
end
