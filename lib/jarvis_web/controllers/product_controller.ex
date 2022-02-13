defmodule JarvisWeb.ProductController do
  use JarvisWeb, :controller

  alias Jarvis.ProductAuthorization
  alias Jarvis.ShoppingLists
  alias Jarvis.ShoppingLists.Product
  alias Jarvis.ShoppingLists.ShoppingListAuthorization

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  plug JarvisWeb.Plugs.RequireAuthorization,
       %{authorization_border: ProductAuthorization} when action in [:edit, :update, :delete]

  def index(conn, %{"shopping_list_id" => shopping_list_id}) do
    redirect(conn, to: Routes.product_path(conn, :new, shopping_list_id))
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

  def create(conn, %{"shopping_list_id" => shopping_list_id, "product" => products_params}) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)

    case ShoppingLists.create_product(products_params, shopping_list) do
      {:ok, _product} ->
        redirect(conn, to: Routes.product_path(conn, :new, shopping_list_id))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> new_form(shopping_list_id, changeset: changeset)
    end
  end

  def edit(conn, %{"shopping_list_id" => shopping_list_id, "id" => product_id}) do
    product = ShoppingLists.get_product!(product_id)
    changeset = ShoppingLists.change_product(product)

    edit_form(conn, shopping_list_id, product, changeset)
  end

  def update(conn, %{
        "shopping_list_id" => shopping_list_id,
        "id" => product_id,
        "product" => product_params
      }) do
    product = ShoppingLists.get_product!(product_id)
    {_, product_params} = Map.pop(product_params, :belongs_to)

    case ShoppingLists.update_product(product, product_params) do
      {:ok, _product} ->
        redirect(conn, to: Routes.product_path(conn, :new, shopping_list_id))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> edit_form(shopping_list_id, product, changeset)
    end
  end

  def delete(conn, %{"shopping_list_id" => shopping_list_id, "id" => product_id}) do
    product = ShoppingLists.get_product!(product_id)
    {:ok, _product} = ShoppingLists.delete_product(product)

    redirect(conn, to: Routes.product_path(conn, :new, shopping_list_id))
  end

  ## Private functions

  defp new_form(conn, shopping_list_id, opts \\ []) do
    changeset = Keyword.get(opts, :changeset, ShoppingLists.change_product(%Product{}))
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    products = ShoppingLists.list_products_by_shopping_list(shopping_list)

    conn
    |> render("new.html", changeset: changeset, shopping_list: shopping_list, products: products)
  end

  defp edit_form(conn, shopping_list_id, product, changeset) do
    shopping_list = ShoppingLists.get_shopping_list!(shopping_list_id)
    products = ShoppingLists.list_products_by_shopping_list(shopping_list)

    conn
    |> render("edit.html",
      changeset: changeset,
      shopping_list: shopping_list,
      products: products,
      product: product
    )
  end

  defp render_unauthorized(conn) do
    conn
    |> put_flash(:error, dgettext("errors", "You are not allow to do this"))
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
