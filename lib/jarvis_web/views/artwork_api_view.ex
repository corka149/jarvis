defmodule JarvisWeb.ArtworkApiView do
  use JarvisWeb, :view
  alias JarvisWeb.ArtworkApiView

  def render("index.json", %{artworks_api: artworks}) do
    %{data: render_many(artworks, ArtworkApiView, "artwork.json")}
  end

  def render("show.json", %{artwork_api: artwork}) do
    %{data: render_one(artwork, ArtworkApiView, "artwork.json")}
  end

  def render("artwork.json", %{artwork_api: artwork}) do
    %{id: artwork.id, name: artwork.name}
  end
end
