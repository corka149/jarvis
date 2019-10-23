defmodule JarvisWeb.Plugs.SetUser do
  @moduledoc """
  Plug for setting the user from user_id contained in the connection.
  """
  import Plug.Conn

  alias Jarvis.Accounts

  require Logger

  def init(_params) do
  end

  def call(conn, _params) do
    conn = fetch_session(conn)
    user_id = get_session(conn, :user_id)

    if user = user_id && Accounts.get_user!(user_id) do
      assign(conn, :user, user)
    else
      Logger.warn("Could not assign an user to the connection.")
      assign(conn, :user, nil)
    end
  end
end
