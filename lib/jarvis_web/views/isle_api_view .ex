defmodule JarvisWeb.IsleApiView do
  use JarvisWeb, :view
  alias JarvisWeb.IsleApiView

  def render("index.json", %{isles_api: isles}) do
    %{data: render_many(isles, IsleApiView, "isle.json")}
  end

  def render("show.json", %{isle_api: isle}) do
    %{data: render_one(isle, IsleApiView, "isle.json")}
  end

  def render("isle.json", %{isle_api: isle}) do
    %{id: isle.id, name: isle.name}
  end
end
