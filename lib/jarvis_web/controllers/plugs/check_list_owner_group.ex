defmodule JarvisWeb.Plugs.CheckListOwnerGroup do
  import Plug.Conn
  import Phoenix.Controller
  import JarvisWeb.Gettext

  alias Jarvis.ShoppingLists

  def init(_params) do
  end

  def call(%{path_params: %{"id" => shopping_list_id}} = conn, _params) do

    if is_in_owner_group(conn.assigns.user.usergroups, shopping_list_id) do
      conn
    else
      conn
      |> put_flash(":error", dgettext("errors", "You are not allow to do this!"))
      |> redirect(to: JarvisWeb.Router.Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  # TODO: At the moment this function gets the group that a user created NOT the groups he belongs to
  @spec is_in_owner_group(any, any) :: boolean
  def is_in_owner_group(usergroups, shopping_list_id) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    Enum.any?(usergroups, fn group -> group.id == shopping_list.usergroup.id end)
  end
end
