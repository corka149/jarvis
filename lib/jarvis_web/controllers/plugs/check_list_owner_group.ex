defmodule JarvisWeb.Plugs.CheckListOwnerGroup do
  @moduledoc """
  Authorization plug for checking if a request has the permission to access
  the a shoppling list.
  """

  import Plug.Conn
  import JarvisWeb.Gettext

  alias Jarvis.Accounts.User
  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.ShoppingList

  require Logger

  def init(_params) do
  end

  def call(%{path_params: %{"id" => shopping_list_id}} = conn, _params) do
    if is_authorized(conn.assigns.user, shopping_list_id) do
      conn
    else
      Logger.warn("User do not belong to owner group.")

      conn
      |> send_resp(403, dgettext("errors", "You are not allow to do this"))
      |> halt()
    end
  end

  def is_authorized(%User{} = user, shopping_list_id) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)

    is_group_member(user.usergroups, shopping_list) or
      is_group_member(user.member_of, shopping_list)
  end

  defp is_group_member(user_groups, %ShoppingList{} = shopping_list) do
    Enum.any?(user_groups, fn group -> group.id == shopping_list.usergroup.id end)
  end
end
