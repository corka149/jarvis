defmodule JarvisWeb.Plugs.CheckListOwnerGroup do
  import Plug.Conn
  import Phoenix.Controller
  import JarvisWeb.Gettext

  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.ShoppingList
  alias Jarvis.Accounts.User

  def init(_params) do
  end

  def call(%{path_params: %{"id" => shopping_list_id}} = conn, _params) do
    if is_authorized(conn.assigns.user, shopping_list_id) do
      conn
    else
      conn
      |> put_flash(:error, dgettext("errors", "You are not allow to do this!"))
      |> redirect(to: JarvisWeb.Router.Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  defp is_authorized(%User{} = user, shopping_list_id) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)

    is_group_member(user.usergroups, shopping_list) or
    is_group_member(user.member_of, shopping_list)
  end

  defp is_group_member(user_groups, %ShoppingList{} = shopping_list) do
    Enum.any?(user_groups, fn group -> group.id == shopping_list.usergroup.id end)
  end
end
