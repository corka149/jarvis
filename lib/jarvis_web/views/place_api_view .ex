defmodule JarvisWeb.PlaceApiView do
  use JarvisWeb, :view
  alias JarvisWeb.PlaceApiView

  def render("index.json", %{places_api: places}) do
    %{data: render_many(places, PlaceApiView, "place.json")}
  end

  def render("show.json", %{place_api: place}) do
    %{data: render_one(place, PlaceApiView, "place.json")}
  end

  def render("place.json", %{place_api: place}) do
    %{id: place.id, name: place.name}
  end
end
