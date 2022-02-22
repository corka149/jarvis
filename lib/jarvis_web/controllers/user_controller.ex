defmodule JarvisWeb.UserController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts.User
  alias Jarvis.Repo.Accounts

  require Logger

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication when action in [:show, :edit, :update, :delete]

  def show(conn, _params) do
    user = Accounts.get_user!(conn.assigns.user.id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, _params) do
    changeset =
      Accounts.get_user!(conn.assigns.user.id)
      |> Accounts.change_user()

    render(conn, "edit.html", changeset: changeset, errors: [])
  end

  def update(conn, %{"user" => user_params}) do
    user = Accounts.get_user!(conn.assigns.user.id)

    case confirm_password_matches?(user_params) do
      :ok ->
        do_update(conn, user, user_params)

      {:error, :not_matching_confirm_password} ->
        changset = Accounts.change_user(user, user_params)

        conn
        |> render("edit.html",
          changeset: changset,
          errors: [confirm_password: {"confirm password does not match", []}]
        )
    end
  end

  def delete(conn, _params) do
    user = Accounts.get_user!(conn.assigns.user.id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      conn
      |> configure_session(drop: true)
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  ## Private functions

  defp confirm_password_matches?(user_params) do
    if Map.get(user_params, "password") != Map.get(user_params, "confirm_password") do
      {:error, :not_matching_confirm_password}
    else
      :ok
    end
  end

  defp do_update(conn, user, user_params) do
    case Accounts.update_user(user, user_params) do
      {:ok, %User{} = _user} ->
        conn
        |> put_flash(:info, dgettext("accounts", "User settings successfull updated."))
        |> redirect(to: Routes.user_path(conn, :show))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> render("edit.html", changeset: changeset, errors: [])
    end
  end
end
