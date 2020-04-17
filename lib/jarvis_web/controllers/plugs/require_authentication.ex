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

  alias Phoenix.Controller
  alias JarvisWeb.Router.Helpers, as: Routes

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

      conn
      |> halt()
      |> Controller.redirect(to: Routes.auth_path(conn, :signin))
    end
  end
end
