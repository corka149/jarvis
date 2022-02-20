defmodule JarvisWeb.Plugs.SetUser do
  @moduledoc """
  Plug for setting the user from user_id contained in the connection.
  """
  import Plug.Conn

  alias Jarvis.Repo.Accounts

  require Logger

  @behaviour Plug

  @impl true
  def init(_params) do
  end

  @impl true
  def call(conn, _params) do
    conn = fetch_session(conn)
    user_id = get_session(conn, :user_id)

    if user = user_id && Accounts.get_user!(user_id) do
      assign(conn, :user, user)
    else
      Logger.info("Could not assign an user to the connection.")
      assign(conn, :user, nil)
    end
  end
end
