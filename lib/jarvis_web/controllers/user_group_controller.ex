defmodule JarvisWeb.UserGroupController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication
  plug :check_user_group_owner when action in [:edit, :update, :delete]

  def index(conn, %{"by_membership" => "true"}) do
    user_groups = Accounts.list_usergroups_by_membership_or_owner(conn.assigns.user)
    render(conn, "index.json", user_groups: user_groups)
  end

  def index(conn, _params) do
    user_groups = Accounts.list_usergroups_by_owner(conn.assigns.user)
    render(conn, "index.json", user_groups: user_groups)
  end

  def show(conn, %{"id" => id}) do
    user_group = Accounts.get_user_group!(id)
    render(conn, "show.json", user_group: user_group)
  end

  def create(conn, %{"user_group" => user_group_params}) do
    with {:ok, user_group} <- Accounts.create_user_group(user_group_params, conn.assigns.user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_group_path(conn, :show, user_group))

      render(conn, "show.json", user_group: user_group)
    end
  end

  def update(conn, %{"id" => id, "user_group" => user_group_params}) do
    user_group = Accounts.get_user_group!(id)

    with {:ok, user_group} <- Accounts.update_user_group(user_group, user_group_params) do
      conn
      |> render("show.json", user_group: user_group)
    end
  end

  def delete(conn, %{"id" => id}) do
    {:ok, _user_group} =
      id
      |> Accounts.get_user_group!()
      |> Accounts.delete_user_group()

    send_resp(conn, :no_content, "")
  end

  def leave_group(conn, %{"id" => id}) do
    user = conn.assigns.user
    user_group = Accounts.get_user_group!(id)

    with :ok <- Accounts.delete_user_from_group(user, user_group) do
      send_resp(conn, :no_content, "")
    end
  end

  def check_user_group_owner(conn, _params) do
    %{params: %{"id" => user_group_id}} = conn

    if Accounts.get_user_group!(user_group_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> halt()
    end
  end
end
