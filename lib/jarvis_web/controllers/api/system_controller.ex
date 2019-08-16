defmodule JarvisWeb.Api.SystemController do
  use JarvisWeb, :controller

  action_fallback JarvisWeb.FallbackController

  def ready(conn, _params) do
    conn
    |> resp(:ok, "jARVIS is ready")
  end

end
