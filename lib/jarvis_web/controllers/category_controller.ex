defmodule JarvisWeb.CategoryController do
  use JarvisWeb, :controller

  alias Jarvis.Finances
  alias Jarvis.Finances.Category
  alias Jarvis.Finances.CategoryAuthorization

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication
  plug JarvisWeb.Plugs.RequireAuthorization, %{authorization_border: CategoryAuthorization} when action in [:show, :update, :delete]

  def index(conn, _params) do
    categories = Finances.list_categories(conn.assigns.user)
    render(conn, "index.json", categories: categories)
  end

  def create(conn, %{"category" => category_params}) do

    with {:ok, %Category{} = category} <- Finances.create_category(category_params, conn.assigns.user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.category_path(conn, :show, category))
      |> render("show.json", category: category)
    end
  end

  def show(conn, %{"id" => id}) do
    category = Finances.get_category!(id)
    render(conn, "show.json", category: category)
  end

  def update(conn, %{"id" => id, "category" => category_params}) do
    category = Finances.get_category!(id)

    with {:ok, %Category{} = category} <- Finances.update_category(category, category_params) do
      render(conn, "show.json", category: category)
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Finances.get_category!(id)

    with {:ok, %Category{}} <- Finances.delete_category(category) do
      send_resp(conn, :no_content, "")
    end
  end
end
