defmodule JarvisWeb.UserController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts.User
  alias Jarvis.Accounts.UserAuthorization

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication
  plug JarvisWeb.Plugs.RequireAuthorization, %{authorization_border: UserAuthorization} when action in [:show, :update, :delete]

  def create(conn, %{"user" => _user_params}) do
    user = %User{}

    conn
    |> put_status(:created)
    |> put_resp_header("location", Routes.user_path(conn, :show, user))
  end

  def show(conn, %{"id" => _id}) do
    conn
  end

  def update(conn, %{"id" => _id, "user" => _user_Params}) do
    conn
    |> put_status(:ok)
  end

  def delete(conn, %{"id" => _id}) do
    conn
  end
end
