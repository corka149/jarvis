defmodule JarvisWeb.AuthController do
  use JarvisWeb, :controller
  plug Ueberauth

  alias Jarvis.Accounts
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
    signin_by_provider(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> send_resp(:no_content, "")
  end

  def signin_by_jarvis(conn, params) do
    params
    |> verify_user()
    |> signin(conn)
  end

  defp signin_by_provider(conn, changeset) do
    changeset
    |> insert_or_update_user()
    |> signin(conn)
  end

  # Adds or updates user from oauth provider
  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end

  # Adds cookie
  defp signin({:ok, user}, conn) do
    conn
    |> put_session(:user_id, user.id)
    |> send_resp(:no_content, "")
  end
  # Or not
  defp signin({:error, _reason}, conn) do
    send_resp(conn, 403, "Error signing in")
  end

  # Check credentials for jarvis user
  defp verify_user(%{"password" => password, "email" => email}) do
    email
    |> Accounts.get_user_by_email()
    |> Argon2.check_pass(password)
  end
  defp verify_user(_) do
    {:error, "missing credentials"}
  end
end
