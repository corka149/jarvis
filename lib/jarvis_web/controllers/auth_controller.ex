defmodule JarvisWeb.AuthController do
  use JarvisWeb, :controller
  plug Ueberauth

  alias Jarvis.Accounts.User
  alias Jarvis.Repo

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      name: auth.info.nickname,
      provider: "github"
    }

    changeset = User.changeset(%User{}, user_params)
    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> send_resp(:no_content, "")

      {:error, _reason} ->
        send_resp(conn, 403, "Error signing in")
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end
end
