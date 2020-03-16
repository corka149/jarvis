defmodule JarvisWeb.PageController do
  use JarvisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
