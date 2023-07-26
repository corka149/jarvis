defmodule JarvisWeb.Plugs.RequireAuthorization do
  @moduledoc """
  Operates on structs that have a created_by field which represents the creator.
  Examples are Jarvis.ShoppingLists.Item or Jarvis.ShoppingLists.ShoppingList.

      iex> # Usage
      iex> plug JarvisWeb.Plugs.RequireAuthorization, %{authorization_border: ShoppingListAuthorization} when action in [:show, :update, :delete]
  """

  require Logger

  import Plug.Conn
  import JarvisWeb.Gettext

  @behaviour Plug

  @impl true
  def init(params) do
    params
  end

  @impl true
  def call(%{path_params: %{"id" => id}} = conn, %{authorization_border: border} = _params) do
    if border.is_allowed_to_cross?(conn.assigns.user, id) do
      conn
    else
      reject(conn)
    end
  end

  @impl true
  def call(conn, %{authorization_border: border} = _params) do
    if border.is_allowed_to_cross?(conn.assigns.user) do
      conn
    else
      reject(conn)
    end
  end

  defp reject(conn) do
    Logger.warning("User does not own target.")

    conn
    |> send_resp(403, dgettext("errors", "You are not allow to do this"))
    |> halt()
  end
end
