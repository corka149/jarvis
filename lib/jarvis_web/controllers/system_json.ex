defmodule JarvisWeb.SystemJSON do
  use JarvisWeb, :html

  def render("ready.json", %{statuses: statuses}) do
    statuses
  end
end
