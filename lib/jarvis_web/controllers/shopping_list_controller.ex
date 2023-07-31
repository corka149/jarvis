defmodule JarvisWeb.ShoppingListController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts.User
  alias Jarvis.AccountsRepo
  alias Jarvis.ShoppingListsRepo
  alias Jarvis.ShoppingLists.{ShoppingList, ShoppingListAuthorization}

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  plug JarvisWeb.Plugs.RequireAuthorization,
       %{authorization_border: ShoppingListAuthorization} when action in [:show, :update, :delete]

  def index(conn, _params) do
    shopping_lists =
      conn.assigns.user
      |> ShoppingListsRepo.list_shoppinglists_for_user()

    conn
    |> render(:index, shopping_lists: shopping_lists)
  end

  def index_open_lists(conn, _params) do
    shopping_lists = ShoppingListsRepo.list_open_shoppinglists(conn.assigns.user)

    conn
    |> render(:index_open_lists, shopping_lists: shopping_lists)
  end

  def show(conn, %{"id" => id}) do
    shopping_list = ShoppingListsRepo.get_shopping_list!(id)

    conn
    |> render(:show, shopping_list: shopping_list)
  end

  def new(conn, _params) do
    changeset = ShoppingListsRepo.change_shopping_list(%ShoppingList{})

    conn
    |> render(:new,
      changeset: changeset,
      user_groups: group_names_with_ids(conn.assigns.user)
    )
  end

  def create(conn, %{"shopping_list" => %{"belongs_to" => user_group_id} = shopping_list_params}) do
    user_group = AccountsRepo.get_user_group!(user_group_id)

    case ShoppingListsRepo.create_shopping_list(shopping_list_params, user_group) do
      {:ok, shopping_list} ->
        conn
        |> put_flash(:info, dgettext("shoppinglists", "Sucessful created shopping list"))
        |> redirect(to: Routes.shopping_list_path(conn, :show, shopping_list))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:new,
          changeset: changeset,
          user_groups: group_names_with_ids(conn.assigns.user)
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    shopping_list = ShoppingListsRepo.get_shopping_list!(id)
    changeset = shopping_list |> ShoppingListsRepo.change_shopping_list()

    conn
    |> render(:edit,
      changeset: changeset,
      user_groups: group_names_with_ids(conn.assigns.user),
      shopping_list: shopping_list
    )
  end

  def update(conn, %{"id" => id, "shopping_list" => shopping_list_params}) do
    shopping_list = ShoppingListsRepo.get_shopping_list!(id)
    {_, shopping_list_params} = Map.pop(shopping_list_params, :belongs_to)

    case ShoppingListsRepo.update_shopping_list(shopping_list, shopping_list_params) do
      {:ok, shopping_list} ->
        redirect(conn, to: Routes.shopping_list_path(conn, :show, shopping_list))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:edit,
          changeset: changeset,
          user_groups: group_names_with_ids(conn.assigns.user),
          shopping_list: shopping_list
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    shopping_list = ShoppingListsRepo.get_shopping_list!(id)
    {:ok, _shopping_list} = ShoppingListsRepo.delete_shopping_list(shopping_list)

    conn
    |> redirect(to: Routes.shopping_list_path(conn, :index))
  end

  ## Private functions

  defp group_names_with_ids(%User{} = user) do
    AccountsRepo.list_usergroups_by_membership_or_owner(user)
    |> Enum.map(&{&1.name, &1.id})
  end
end
