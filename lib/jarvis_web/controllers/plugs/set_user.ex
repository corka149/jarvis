defmodule JarvisWeb.Plugs.SetUser do
  @moduledoc """
  Plug for setting the user from user_id contained in the connection.
  """
  import Plug.Conn

  alias Jarvis.AccountsRepo

  require Logger

  @behaviour Plug

  @impl true
  def init(_params) do
  end

  @impl true
  def call(%{req_headers: req_headers} = conn, _params) do
    conn = fetch_session(conn)
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && AccountsRepo.get_user!(user_id) ->
        assign(conn, :user, user)

      header = find_api_header(req_headers) ->
        {"authorization", token} = header
        assign_user_from_token(conn, token)

      :else ->
        assign_no_user(conn)
    end
  end

  defp find_api_header(headers) do
    headers
    |> Enum.find(fn {name, val} -> name == "authorization" and val end)
  end

  defp assign_user_from_token(conn, token) do
    case Ecto.UUID.cast(token) do
      {:ok, token} ->
        user = AccountsRepo.get_user_by_token!(token)
        assign(conn, :user, user)

      :error ->
        assign_no_user(conn)
    end
  end

  def assign_no_user(conn) do
    Logger.info("Could not assign an user to the connection.")
    assign(conn, :user, nil)
  end
end
