defmodule JarvisWeb.ArtworkController do
  use JarvisWeb, :controller

  action_fallback JarvisWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
