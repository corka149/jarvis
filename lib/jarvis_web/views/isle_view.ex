defmodule JarvisWeb.IsleView do
  use JarvisWeb, :view
  alias JarvisWeb.IsleView

  def render("index.json", %{isles: isles}) do
    %{data: render_many(isles, IsleView, "isle.json")}
  end

  def render("show.json", %{isle: isle}) do
    %{data: render_one(isle, IsleView, "isle.json")}
  end

  def render("isle.json", %{isle: isle}) do
    %{id: isle.id, name: isle.name}
  end
end
