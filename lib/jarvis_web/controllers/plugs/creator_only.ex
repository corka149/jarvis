defmodule JarvisWeb.Plugs.CreatorOnly do
  @moduledoc """
  Operates on structs that have a created_by field which represents the creator.
  Examples are Jarvis.Finances.Category or Jarvis.Finances.Transaction.

      iex> # Usage
      iex> plug JarvisWeb.Plugs.CreatorOnly, %{query_function: &Finances.get_transaction!/1} when action in [:show, :update, :delete]
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
  def call(%{path_params: %{"id" => id}} = conn, %{query_function: query_function} = _params) do
    if is_owner? id, conn.assigns.user, query_function do
      conn
    else
      reject conn
    end
  end

  defp is_owner?(target_id, user, query_function) do
    target = query_function.(target_id)
    target.created_by == user.id
  end

  defp reject(conn) do
    Logger.info("User does not own target.")

    conn
    |> send_resp(403, dgettext("errors", "You are not allow to do this"))
    |> halt()
  end
end
