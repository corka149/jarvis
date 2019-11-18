defmodule JarvisWeb.AuthControllerTest do

  use JarvisWeb.ConnCase
  use Plug.Test

  @user_password "THIS#15-password"

  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "jarvis",
    token: "some token",
    password: @user_password
  }

  setup %{conn: conn} do
    {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

    conn = conn
            |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user: user}
  end

  test "connect with valid credentials and expect success", %{conn: conn, user: user} do
    credentials = %{"email" => user.email, "password" => @user_password}
    signin_response = post(conn, Routes.auth_path(conn, :signin_by_jarvis), credentials)
    assert response(signin_response, :no_content) =~ ""
  end

  test "connect with invalid credentials and expect rejection", %{conn: conn, user: user} do
    credentials = %{"email" => user.email, "password" => "wrong_password"}
    signin_response = post(conn, Routes.auth_path(conn, :signin_by_jarvis), credentials)
    assert response(signin_response, 403) =~ "Error signing in"
  end

  test "sign out from session", %{conn: conn, user: user} do
    credentials = %{"email" => user.email, "password" => @user_password}
    signin_response = post(conn, Routes.auth_path(conn, :signin_by_jarvis), credentials)
    get_user_conn = get(signin_response, Routes.user_path(conn, :show, user.id))
    response get_user_conn, 200

    signout_response = get(get_user_conn, Routes.auth_path(conn, :signout))
    assert response(signout_response, 204) =~ ""
    get_user_conn = get(signout_response, Routes.user_path(conn, :show, user.id))
    response get_user_conn, 401
  end
end
