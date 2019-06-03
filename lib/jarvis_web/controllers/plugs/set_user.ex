defmodule JarvisWeb.Plugs.SetUser do
  import Plug.Conn

  alias Jarvis.Accounts

  require Logger

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Accounts.get_user!(user_id) ->
        assign(conn, :user, user)
      true                                      ->
        Logger.warn("Could not assign an user to the connection.")
        assign(conn, :user, nil)
    end

  end

end
