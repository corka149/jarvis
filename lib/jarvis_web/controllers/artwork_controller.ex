defmodule JarvisWeb.ArtworkController do
  use JarvisWeb, :controller

  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Artwork

  action_fallback JarvisWeb.FallbackController

  def index(conn, _params) do
    artworks = AnimalXing.list_artworks()
    render(conn, "index.json", artworks: artworks)
  end

  def create(conn, %{"artwork" => artwork_params}) do
    with {:ok, %Artwork{} = artwork} <- AnimalXing.create_artwork(artwork_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.artwork_path(conn, :show, artwork))
      |> render("show.json", artwork: artwork)
    end
  end

  def show(conn, %{"id" => id}) do
    artwork = AnimalXing.get_artwork!(id)
    render(conn, "show.json", artwork: artwork)
  end

  def update(conn, %{"id" => id, "artwork" => artwork_params}) do
    artwork = AnimalXing.get_artwork!(id)

    with {:ok, %Artwork{} = artwork} <- AnimalXing.update_artwork(artwork, artwork_params) do
      render(conn, "show.json", artwork: artwork)
    end
  end

  def delete(conn, %{"id" => id}) do
    artwork = AnimalXing.get_artwork!(id)

    with {:ok, %Artwork{}} <- AnimalXing.delete_artwork(artwork) do
      send_resp(conn, :no_content, "")
    end
  end
end
