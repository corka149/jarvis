defmodule JarvisWeb.AuthController do
  use JarvisWeb, :controller
  plug Ueberauth

  alias Jarvis.Accounts
  alias Jarvis.Accounts.User
  alias Jarvis.Repo

  @doc """
  OAuth callback
  """
  @spec callback(Plug.Conn.t(), any) :: Plug.Conn.t()
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

  def signin_by_jarvis(conn, params) do
    params
    |> verify_user()
    |> init_session(conn)
  end

  def signin(conn, _params) do
    render(conn, "signin.html")
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  ## Private functions

  defp signin_by_provider(conn, changeset) do
    changeset
    |> insert_or_update_user()
    |> init_session(conn)
  end

  # Adds or updates user from oauth provider
  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end

  # Adds cookie
  defp init_session({:ok, user}, conn) do
    conn
    |> put_session(:user_id, user.id)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  # Or not
  defp init_session({:error, _reason}, conn) do
    conn
    |> put_flash(:error, dgettext("accounts","Sign in failed"))
    |> put_status(403)
    |> render("signin.html")
  end

  # Check credentials for jarvis user
  defp verify_user(%{"password" => password, "email" => email}) do
    case email |> Accounts.get_user_by_email() do
      %{provider: "jarvis"} = user -> Argon2.check_pass(user, password)
      _ -> {:error, "Not a jARVIS user"}
    end
  end

  defp verify_user(_) do
    {:error, "missing credentials"}
  end
end
