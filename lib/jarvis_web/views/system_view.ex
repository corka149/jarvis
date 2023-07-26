defmodule JarvisWeb.SystemView do
  use JarvisWeb, :view

  def render("ready.json", %{statuses: statuses}) do
    statuses
  end
end
