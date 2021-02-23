defmodule JarvisWeb.IsleController do
  use JarvisWeb, :controller

  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Isle

  action_fallback JarvisWeb.FallbackController

  def index_html(conn, _params) do
    render(conn, "index.html")
  end

  def index(conn, _params) do
    isles = AnimalXing.list_isles()
    render(conn, "index.json", isles: isles)
  end

  def create(conn, %{"isle" => %{"owned_by" => owned_by} = isle_params}) do
    user_group = Jarvis.Accounts.get_user_group!(owned_by)

    with {:ok, %Isle{} = isle} <- AnimalXing.create_isle(isle_params, user_group) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.isle_path(conn, :show, isle))
      |> render("show.json", isle: isle)
    end
  end

  def show(conn, %{"id" => id}) do
    isle = AnimalXing.get_isle!(id)
    render(conn, "show.json", isle: isle)
  end

  def update(conn, %{"id" => id, "isle" => isle_params}) do
    isle = AnimalXing.get_isle!(id)

    with {:ok, %Isle{} = isle} <- AnimalXing.update_isle(isle, isle_params) do
      render(conn, "show.json", isle: isle)
    end
  end

  def delete(conn, %{"id" => id}) do
    isle = AnimalXing.get_isle!(id)

    with {:ok, %Isle{}} <- AnimalXing.delete_isle(isle) do
      send_resp(conn, :no_content, "")
    end
  end
end
