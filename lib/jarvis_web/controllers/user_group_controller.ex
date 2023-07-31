defmodule JarvisWeb.UserGroupController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts.UserGroup
  alias Jarvis.AccountsRepo

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication
  plug :check_user_group_owner when action in [:edit, :update, :delete]

  def index(conn, %{"by_membership" => "true"}) do
    user_groups = AccountsRepo.list_usergroups_by_membership_or_owner(conn.assigns.user)
    render(conn, :index, user_groups: user_groups)
  end

  def index(conn, _params) do
    user_groups = AccountsRepo.list_usergroups_by_owner(conn.assigns.user)
    render(conn, :index, user_groups: user_groups)
  end

  def show(conn, %{"id" => id}) do
    user_group = AccountsRepo.get_user_group!(id)
    render(conn, :show, user_group: user_group)
  end

  def new(conn, _params) do
    changeset = AccountsRepo.change_user_group(%UserGroup{})

    conn
    |> render(:new, changeset: changeset)
  end

  def create(conn, %{"user_group" => user_group_params}) do
    case AccountsRepo.create_user_group(user_group_params, conn.assigns.user) do
      {:ok, user_group} ->
        conn
        |> put_flash(:info, dgettext("accounts", "Sucessful created user group"))
        |> redirect(to: Routes.user_group_path(conn, :show, user_group))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user_group = AccountsRepo.get_user_group!(id)

    changeset =
      user_group
      |> AccountsRepo.change_user_group()

    conn
    |> render(:edit, changeset: changeset, user_group: user_group)
  end

  def update(conn, %{"id" => id, "user_group" => user_group_params}) do
    user_group = AccountsRepo.get_user_group!(id)

    case AccountsRepo.update_user_group(user_group, user_group_params) do
      {:ok, user_group} ->
        conn
        |> redirect(to: Routes.user_group_path(conn, :show, user_group))

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:edit, changeset: changeset, user_group: user_group)
    end
  end

  def delete(conn, %{"id" => id}) do
    {:ok, _user_group} =
      id
      |> AccountsRepo.get_user_group!()
      |> AccountsRepo.delete_user_group()

    conn
    |> redirect(to: Routes.user_group_path(conn, :index))
  end

  def leave_group(conn, %{"id" => id}) do
    user = conn.assigns.user
    user_group = AccountsRepo.get_user_group!(id)

    with :ok <- AccountsRepo.delete_user_from_group(user, user_group) do
      redirect(conn, to: Routes.invitation_path(conn, :index))
    end
  end

  def check_user_group_owner(conn, _params) do
    %{params: %{"id" => user_group_id}} = conn

    if AccountsRepo.get_user_group!(user_group_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> halt()
    end
  end
end
