defmodule JarvisWeb.IsleApiController do
  use JarvisWeb, :controller

  alias Jarvis.Inventory
  alias Jarvis.Inventory.Isle

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index_html(conn, _params) do
    render(conn, "index.html")
  end

  def index(conn, _params) do
    isles = Inventory.list_isles()
    render(conn, "index.json", isles_api: isles)
  end

  def create(conn, %{"isle" => %{"owned_by" => owned_by} = isle_params}) do
    user_group = Jarvis.Accounts.get_user_group!(owned_by)

    with {:ok, %Isle{} = isle} <- Inventory.create_isle(isle_params, user_group) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.isle_api_path(conn, :show, isle))
      |> render("show.json", isle_api: isle)
    end
  end

  def show(conn, %{"id" => id}) do
    isle = Inventory.get_isle!(id)
    render(conn, "show.json", isle_api: isle)
  end

  def update(conn, %{"id" => id, "isle" => isle_params}) do
    isle = Inventory.get_isle!(id)

    with {:ok, %Isle{} = isle} <- Inventory.update_isle(isle, isle_params) do
      render(conn, "show.json", isle_api: isle)
    end
  end

  def delete(conn, %{"id" => id}) do
    isle = Inventory.get_isle!(id)

    with {:ok, %Isle{}} <- Inventory.delete_isle(isle) do
      send_resp(conn, :no_content, "")
    end
  end
end
