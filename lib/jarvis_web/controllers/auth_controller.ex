defmodule JarvisWeb.AuthController do
  use JarvisWeb, :controller

  alias Jarvis.Repo.Accounts

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

  # Adds cookie
  defp init_session({:ok, user}, conn) do
    conn
    |> put_session(:user_id, user.id)
    |> redirect(to: Routes.page_path(conn, :index))
  end

  # Or not
  defp init_session({:error, _reason}, conn) do
    conn
    |> put_flash(:error, dgettext("accounts", "Sign in failed"))
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
