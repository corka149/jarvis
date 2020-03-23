defmodule JarvisWeb.UserController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.Accounts.User

  require Logger

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication when action in [:show, :edit, :update, :delete]

  def show(conn, _params) do
    user = Accounts.get_user!(conn.assigns.user.id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    user = Accounts.get_user!(conn.assigns.user.id)
            |> User.changeset(%{})

    render(conn, "edit.html",  changeset: user)
  end

  def update(conn, %{"user" => user_params}) do
    user = Accounts.get_user!(conn.assigns.user.id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.html", user: user)
    end
  end

  def delete(conn, _params) do
    user = Accounts.get_user!(conn.assigns.user.id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      redirect(conn, to: Routes.page_path(conn, :index))
    end
  end

end
