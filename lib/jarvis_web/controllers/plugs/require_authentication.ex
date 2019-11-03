defmodule JarvisWeb.Plugs.RequireAuthentication do
  @moduledoc """
  Use this plug in a controller, when authentication is require to access routes.

  E.g. for adding it to a controller:
  ```
  plug JarvisWeb.Plugs.RequireAuthentication when action in [:new, :edit; :delete]
  ```
  (The list at the end represents the functions for which the plug should be applied.)
  """

  require Logger

  import Plug.Conn
  import JarvisWeb.Gettext

  @behaviour Plug

  @impl true
  def init(_params) do
  end

  @impl true
  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      Logger.info("Request without authentication occured.")

      conn
      |> send_resp(401, dgettext("errors", "You must be logged in"))
      |> halt()
    end
  end
end