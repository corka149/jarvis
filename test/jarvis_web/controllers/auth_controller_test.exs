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

  setup do
    {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
    {:ok, user: user}
  end

  test "connect with valid credentials and expect success", %{conn: conn, user: user} do
    credentials = %{"email" => user.email, "password" => @user_password}
    signin_response = post(conn, Routes.auth_path(conn, :signin_by_jarvis), credentials)
    assert redirected_to(signin_response) == Routes.page_path(conn, :index)
  end

  test "connect with invalid credentials and expect rejection", %{conn: conn, user: user} do
    credentials = %{"email" => user.email, "password" => "wrong_password"}
    signin_response = post(conn, Routes.auth_path(conn, :signin_by_jarvis), credentials)
    assert response(signin_response, 403) =~ "Sign in failed"
  end

  test "sign out from session", %{conn: conn, user: user} do
    credentials = %{"email" => user.email, "password" => @user_password}
    signin_response = post(conn, Routes.auth_path(conn, :signin_by_jarvis), credentials)
    get_user_conn = get(signin_response, Routes.user_path(conn, :show))
    response(get_user_conn, 200)

    signout_response = get(get_user_conn, Routes.auth_path(conn, :signout))
    assert redirected_to(signout_response) == Routes.page_path(conn, :index)
    get_user_conn = get(signout_response, Routes.user_path(conn, :show))
    response(get_user_conn, 401)
  end
end
