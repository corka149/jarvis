defmodule JarvisWeb.Api.SystemController do
  use JarvisWeb, :controller

  action_fallback JarvisWeb.FallbackController

  def ready(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> resp(:ok, "jARVIS is ready")
  end

end
