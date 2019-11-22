defmodule JarvisWeb.UserController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.Accounts.User
  alias Jarvis.Accounts.UserAuthorization

  @empty_name_faultback "empty"

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication when action in [:show, :update, :delete]

  plug JarvisWeb.Plugs.RequireAuthorization,
       %{authorization_border: UserAuthorization} when action in [:show, :update, :delete]

  def create(conn, %{"user" => user_params}) do
    user_params = add_jarvis_details(user_params)

    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_Params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_Params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  ## Private functions

  defp add_jarvis_details(user_params) do
    name =
      case Map.get(user_params, "name", @empty_name_faultback) do
        nil -> @empty_name_faultback
        name -> name
      end

    token = Base.encode16(:crypto.hash(:sha256, "jarvis:" <> name))

    user_params
    |> Map.put("provider", "jarvis")
    |> Map.put("token", token)
  end
end
