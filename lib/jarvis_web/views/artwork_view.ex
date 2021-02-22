defmodule JarvisWeb.ArtworkView do
  use JarvisWeb, :view
  alias JarvisWeb.ArtworkView

  def render("index.json", %{artworks: artworks}) do
    %{data: render_many(artworks, ArtworkView, "artwork.json")}
  end

  def render("show.json", %{artwork: artwork}) do
    %{data: render_one(artwork, ArtworkView, "artwork.json")}
  end

  def render("artwork.json", %{artwork: artwork}) do
    %{id: artwork.id, name: artwork.name}
  end
end
