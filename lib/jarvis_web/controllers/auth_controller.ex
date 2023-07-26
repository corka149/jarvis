defmodule JarvisWeb.AuthController do
  use JarvisWeb, :controller

  alias Jarvis.AccountsAppService

  def signin_by_jarvis(conn, params) do
    params
    |> AccountsAppService.verify_user()
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
end
