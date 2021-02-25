defmodule JarvisWeb.Plugs.RequireAuthentication do
  @moduledoc """
  Use this plug in a controller, when authentication is require to access routes.

  E.g. for adding it to a controller:
  ```
  plug JarvisWeb.Plugs.RequireAuthentication when action in [:new, :edit; :delete]
  ```
  (The list at the end represents the functions for which the plug should be applied.)
  """

  import Plug.Conn
  require Logger

  alias JarvisWeb.Router.Helpers, as: Routes
  alias Phoenix.Controller

  @behaviour Plug

  @impl true
  def init(_params) do
  end

  @impl true
  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      Logger.warn("Request without authentication occured.")
      decline(conn)
    end
  end

  defp decline(%{req_headers: req_headers} = conn) do
    if is_api_req?(req_headers) do
      conn
      |> halt()
      |> put_status(401)
      |> Controller.text("UNAUTHORIZED")
    else
      conn
      |> halt()
      |> Controller.redirect(to: Routes.auth_path(conn, :signin))
    end
  end

  defp is_api_req?(req_headers) when is_list(req_headers) do
    Enum.any?(req_headers, fn {key, val} -> key == "accept" and val == "application/json" end)
  end
end
