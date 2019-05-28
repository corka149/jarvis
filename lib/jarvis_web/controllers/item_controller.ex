defmodule JarvisWeb.ItemController do
  use JarvisWeb, :controller

  alias Phoenix.LiveView
  alias Jarvis.Accounts

  plug JarvisWeb.Plugs.RequireAuth
  plug :belongs_to_owner_group

  def index(conn, %{"shopping_list_id" => shopping_list_id}) do

    LiveView.Controller.live_render(conn, JarvisWeb.ItemLive, session: %{
      shopping_list_id: shopping_list_id,
      current_user_id: get_session(conn, :user_id),
    })
  end

  def belongs_to_owner_group(conn, params) do
    IO.puts "Success"
    conn
  end
end
