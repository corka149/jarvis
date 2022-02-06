defmodule JarvisWeb.PlaceApiController do
  use JarvisWeb, :controller

  alias Jarvis.Inventory
  alias Jarvis.Inventory.Place

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication

  def index_html(conn, _params) do
    render(conn, "index.html")
  end

  def index(conn, _params) do
    places = Inventory.list_places()
    render(conn, "index.json", places_api: places)
  end

  def create(conn, %{"place" => %{"owned_by" => owned_by} = place_params}) do
    user_group = Jarvis.Accounts.get_user_group!(owned_by)

    with {:ok, %Place{} = place} <- Inventory.create_place(place_params, user_group) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.place_api_path(conn, :show, place))
      |> render("show.json", place_api: place)
    end
  end

  def show(conn, %{"id" => id}) do
    place = Inventory.get_place!(id)
    render(conn, "show.json", place_api: place)
  end

  def update(conn, %{"id" => id, "place" => place_params}) do
    place = Inventory.get_place!(id)

    with {:ok, %Place{} = place} <- Inventory.update_place(place, place_params) do
      render(conn, "show.json", place_api: place)
    end
  end

  def delete(conn, %{"id" => id}) do
    place = Inventory.get_place!(id)

    with {:ok, %Place{}} <- Inventory.delete_place(place) do
      send_resp(conn, :no_content, "")
    end
  end
end
