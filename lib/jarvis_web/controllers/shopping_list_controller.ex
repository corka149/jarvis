defmodule JarvisWeb.ShoppingListController do
  use JarvisWeb, :controller

  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.ShoppingList

  def index(conn, _params) do
    shoppinglists = ShoppingLists.list_shoppinglists()
    render(conn, "index.html", shoppinglists: shoppinglists)
  end

  def new(conn, _params) do
    changeset = ShoppingLists.change_shopping_list(%ShoppingList{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"shopping_list" => shopping_list_params}) do
    case ShoppingLists.create_shopping_list(shopping_list_params) do
      {:ok, shopping_list} ->
        conn
        |> put_flash(:info, "Shopping list created successfully.")
        |> redirect(to: Routes.shopping_list_path(conn, :show, shopping_list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shopping_list = ShoppingLists.get_shopping_list!(id)
    render(conn, "show.html", shopping_list: shopping_list)
  end

  def edit(conn, %{"id" => id}) do
    shopping_list = ShoppingLists.get_shopping_list!(id)
    changeset = ShoppingLists.change_shopping_list(shopping_list)
    render(conn, "edit.html", shopping_list: shopping_list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shopping_list" => shopping_list_params}) do
    shopping_list = ShoppingLists.get_shopping_list!(id)

    case ShoppingLists.update_shopping_list(shopping_list, shopping_list_params) do
      {:ok, shopping_list} ->
        conn
        |> put_flash(:info, "Shopping list updated successfully.")
        |> redirect(to: Routes.shopping_list_path(conn, :show, shopping_list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", shopping_list: shopping_list, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shopping_list = ShoppingLists.get_shopping_list!(id)
    {:ok, _shopping_list} = ShoppingLists.delete_shopping_list(shopping_list)

    conn
    |> put_flash(:info, "Shopping list deleted successfully.")
    |> redirect(to: Routes.shopping_list_path(conn, :index))
  end
end
