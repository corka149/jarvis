defmodule JarvisWeb.UserController do
  use JarvisWeb, :controller

  alias Jarvis.Accounts
  alias Jarvis.Accounts.User
  alias Jarvis.Accounts.UserAuthorization

  require Logger

  @empty_name_faultback "<empty>"
  @authorization_header "authorization"

  action_fallback JarvisWeb.FallbackController

  plug JarvisWeb.Plugs.RequireAuthentication when action in [:show, :update, :delete]

  plug JarvisWeb.Plugs.RequireAuthorization,
       %{authorization_border: UserAuthorization} when action in [:show, :update, :delete]

  plug :is_authorized_creation when action in [:create]

  def create(conn, %{"user" => user_params}) do
    user_params = add_jarvis_details(user_params)

    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => "current"}) do
    user = Accounts.get_user!(conn.assigns.user.id)
    render(conn, "show.json", user: user)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => "current"} = params) do
    params = %{params | "id" => conn.assigns.user.id}
    update(conn, params)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
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

  ## User creation security

  defp is_authorized_creation(%{req_headers: req_headers} = conn, _params) do
    case Enum.filter(req_headers, fn {name, _value} -> name == @authorization_header end) do
      [] -> reject_request(conn, "Unauthorized creation request")
      [header | _] -> check_authorization(conn, header)
    end
  end

  defp check_authorization(conn, {_name, value} = _header) when is_binary(value) do
    case decode_base64(value) |> decode_uuid4() |> verify_token do
      :ok -> conn
      :error -> reject_request(conn)
    end
  end

  defp check_authorization(conn, _header), do: reject_request(conn)

  defp decode_base64(token), do: Base.decode64(token)

  defp decode_uuid4({:ok, token}) do
    case UUID.info(token) do
      {:ok, _} -> {:ok, token}
      {:error, _} -> :error
    end
  end

  defp decode_uuid4(_), do: :error

  defp verify_token({:ok, token}) do
    if Application.get_env(:jarvis, :authorization_key) == token do
      :ok
    else
      :error
    end
  end

  defp verify_token(_), do: :error

  defp reject_request(conn, msg \\ "Incorrect authorization token") do
    Logger.warn(msg)

    conn
    |> send_resp(403, dgettext("errors", "You are not allow to do this"))
    |> halt()
  end
end
