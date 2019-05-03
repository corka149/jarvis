defmodule JarvisWeb.AuthController do
  use JarvisWeb, :controller
  plug Ueberauth

  alias Jarvis.Repo
  alias Jarvis.Accounts.User
  alias JarvisWeb.Router.Helpers

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, name: auth.info.nickname, provider: "auth0"}
    changeset = User.changeset(%User{}, user_params)
    signin(conn, changeset)
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user}       ->
        conn
        |> put_flash(:info, "Welcome #{user.name}!")
        |> put_session(:user_id, user.id)
        |> redirect(to: Helpers.page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: Helpers.page_path(conn, :index))
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil   -> Repo.insert(changeset)
      user  -> {:ok, user}
    end
  end
end
