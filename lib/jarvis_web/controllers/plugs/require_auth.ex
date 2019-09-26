defmodule JarvisWeb.Plugs.RequireAuth do
  @moduledoc """
  Use this plug in a controller, when authentication is require to access routes.

  E.g. for adding it to a controller:
  ```
  plug JarvisWeb.Plugs.RequireAuth when action in [:new, :edit; :delete]
  ```
  (The list at the end represents the functions for which the plug should be applied.)
  """

  import Plug.Conn
  import Phoenix.Controller

  alias JarvisWeb.Router.Helpers

  require Logger

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      Logger.warn("Request without authentication occured.")

      conn
      |> put_flash(:error, "You must be logged in.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
