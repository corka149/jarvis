defmodule JarvisWeb.SystemController do
  use JarvisWeb, :controller

  def ready(conn, _params) do
    case Application.started_applications()
         |> Enum.find(:not_found, fn {app, _desc, _version} -> app == :jarvis end) do
      :not_found ->
        conn |> put_status(500) |> render("ready.json", statuses: [%{jarvis: "Not started"}])

      {:jarvis, _, _} ->
        conn |> put_status(200) |> render("ready.json", statuses: [%{jarvis: "Was started"}])
    end
  end
end
