defmodule JarvisWeb.ItemController do
  use JarvisWeb, :controller

  alias Jarvis.ItemAuthorization
  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.ShoppingListAuthorization

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  plug JarvisWeb.Plugs.RequireAuthorization,
       %{authorization_border: ItemAuthorization} when action in [:edit, :update, :delete]

  def index(conn, %{"shopping_list_id" => shopping_list_id}) do
    redirect(conn, to: Routes.item_path(conn, :new, shopping_list_id))
  end

  def new(conn, %{"shopping_list_id" => shopping_list_id}) do
    user_available = Map.has_key?(conn.assigns, :user)

    allowed_to_cross? =
      user_available and
        ShoppingListAuthorization.is_allowed_to_cross?(conn.assigns.user, shopping_list_id)

    if allowed_to_cross? do
      new_form(conn, shopping_list_id)
    else
      render_unauthorized(conn)
    end
  end

  def create(conn, %{"shopping_list_id" => shopping_list_id, "item" => items_params}) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)

    case ShoppingLists.create_item(items_params, shopping_list) do
      {:ok, _item} ->
        redirect(conn, to: Routes.item_path(conn, :new, shopping_list_id))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> new_form(shopping_list_id, changeset: changeset)
    end
  end

  def edit(conn, %{"shopping_list_id" => shopping_list_id, "id" => item_id}) do
    item = ShoppingLists.get_item!(item_id)
    changeset = ShoppingLists.change_item(item)

    edit_form(conn, shopping_list_id, item, changeset)
  end

  def update(conn, %{
        "shopping_list_id" => shopping_list_id,
        "id" => item_id,
        "item" => item_params
      }) do
    item = ShoppingLists.get_item!(item_id)
    {_, item_params} = Map.pop(item_params, :belongs_to)

    case ShoppingLists.update_item(item, item_params) do
      {:ok, _item} ->
        redirect(conn, to: Routes.item_path(conn, :new, shopping_list_id))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> edit_form(shopping_list_id, item, changeset)
    end
  end

  def delete(conn, %{"shopping_list_id" => shopping_list_id, "id" => item_id}) do
    item = ShoppingLists.get_item!(item_id)
    {:ok, _item} = ShoppingLists.delete_item(item)

    redirect(conn, to: Routes.item_path(conn, :new, shopping_list_id))
  end

  ## Private functions

  defp new_form(conn, shopping_list_id, opts \\ []) do
    changeset = Keyword.get(opts, :changeset, ShoppingLists.change_item(%ShoppingLists.Item{}))
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    conn
    |> render("new.html", changeset: changeset, shopping_list: shopping_list, items: items)
  end

  defp edit_form(conn, shopping_list_id, item, changeset) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    items = ShoppingLists.list_items_by_shopping_list(shopping_list)

    conn
    |> render("edit.html",
      changeset: changeset,
      shopping_list: shopping_list,
      items: items,
      item: item
    )
  end

  defp render_unauthorized(conn) do
    conn
    |> put_flash(:error, dgettext("errors", "You are not allow to do this"))
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
