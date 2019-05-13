defmodule JarvisWeb.UserGroupController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.Accounts.UserGroup

  plug JarvisWeb.Plugs.RequireAuth
  plug :check_user_group_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    usergroups = Accounts.list_usergroups_by_owner(conn.assigns.user.id)
    render(conn, "index.html", usergroups: usergroups)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user_group(%UserGroup{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user_group" => user_group_params}) do
    case Accounts.create_user_group(user_group_params, conn.assigns.user) do
      {:ok, user_group} ->
        conn
        |> put_flash(:info, "User group created successfully.")
        |> redirect(to: Routes.user_group_path(conn, :show, user_group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user_group = Accounts.get_user_group!(id)
    render(conn, "show.html", user_group: user_group)
  end

  def edit(conn, %{"id" => id}) do
    user_group = Accounts.get_user_group!(id)
    changeset = Accounts.change_user_group(user_group)
    render(conn, "edit.html", user_group: user_group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user_group" => user_group_params}) do
    user_group = Accounts.get_user_group!(id)

    case Accounts.update_user_group(user_group, user_group_params) do
      {:ok, user_group} ->
        conn
        |> put_flash(:info, "User group updated successfully.")
        |> redirect(to: Routes.user_group_path(conn, :show, user_group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user_group: user_group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user_group = Accounts.get_user_group!(id)
    {:ok, _user_group} = Accounts.delete_user_group(user_group)

    conn
    |> put_flash(:info, "User group deleted successfully.")
    |> redirect(to: Routes.user_group_path(conn, :index))
  end

  def check_user_group_owner(conn, _params) do
    %{params: %{"id" => user_group_id}} = conn

    if Accounts.get_user_group!(user_group_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(":error", dgettext("errors", "You are not allow to do this!"))
      |> redirect(to: JarvisWeb.Router.Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
