defmodule JarvisWeb.ItemController do
  use JarvisWeb, :controller

  alias Phoenix.LiveView

  plug JarvisWeb.Plugs.RequireAuth
  plug JarvisWeb.Plugs.CheckListOwnerGroup

  def index(conn, %{"shopping_list_id" => shopping_list_id}) do

    LiveView.Controller.live_render(conn, JarvisWeb.ItemLive, session: %{
      shopping_list_id: shopping_list_id,
      current_user_id: get_session(conn, :user_id),
    })
  end
end
