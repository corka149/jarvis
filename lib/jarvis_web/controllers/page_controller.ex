defmodule JarvisWeb.PageController do
  alias JarvisWeb.Router.Helpers
  alias Jarvis.Accounts

  use JarvisWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def set_language(conn, %{"language" => language}) do
    case Accounts.update_user(conn.assigns.user, %{default_language: language}) do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Language updated!"))
        |> redirect(to: Helpers.page_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, gettext("Couldn't update default language"))
        |> redirect(to: Helpers.page_path(conn, :index))
    end

  end
end
