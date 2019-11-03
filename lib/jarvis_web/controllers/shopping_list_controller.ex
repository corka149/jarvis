defmodule JarvisWeb.ShoppingListController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.ShoppingList
  alias JarvisWeb.ShoppingListController

  @behaviour JarvisWeb.AuthorizationBorder

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication
  plug JarvisWeb.Plugs.RequireAuthorization, %{authorization_border: ShoppingListController} when action in [:show, :update, :delete]

  def index(conn, _params) do
    shoppinglists =
      conn.assigns.user
      |> ShoppingLists.list_shoppinglists_for_user()

    render(conn, "index.json", shopping_lists: shoppinglists)
  end

  def index_open_lists(conn, _params) do
    shoppinglists = ShoppingLists.list_open_shoppinglists(conn.assigns.user)
    render(conn, "index.json", shopping_lists: shoppinglists)
  end

  def show(conn, %{"id" => id}) do
    shopping_list = ShoppingLists.get_shopping_list!(id)
    render(conn, "show.json", shopping_list: shopping_list)
  end

  def create(conn, %{"shopping_list" => %{"belongs_to" => user_group_id} = shopping_list_params}) do
    user_group = Accounts.get_user_group!(user_group_id)

    with {:ok, shopping_list} <-
           ShoppingLists.create_shopping_list(shopping_list_params, user_group) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.shopping_list_path(conn, :show, shopping_list))
      |> render("show.json", shopping_list: shopping_list)
    end
  end

  def update(conn, %{"id" => id, "shopping_list" => shopping_list_params}) do
    shopping_list = ShoppingLists.get_shopping_list!(id)
    {_, shopping_list_params} = Map.pop(shopping_list_params, :belongs_to)

    with {:ok, shopping_list} <-
           ShoppingLists.update_shopping_list(shopping_list, shopping_list_params) do
      render(conn, "show.json", shopping_list: shopping_list)
    end
  end

  def delete(conn, %{"id" => id}) do
    shopping_list = ShoppingLists.get_shopping_list!(id)
    {:ok, _shopping_list} = ShoppingLists.delete_shopping_list(shopping_list)

    send_resp(conn, :no_content, "")
  end

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
