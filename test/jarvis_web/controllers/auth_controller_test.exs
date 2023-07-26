defmodule JarvisWeb.AuthControllerTest do
  alias Jarvis.AccountsRepo

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
    {:ok, user} = AccountsRepo.create_user(@valid_attrs_user)
    {:ok, user: user}
  end

  # ===== TESTS =====

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
    conn = post(conn, Routes.auth_path(conn, :signin_by_jarvis), credentials)
    conn = get(conn, Routes.user_path(conn, :show))
    response(conn, 200)

    conn = get(conn, Routes.auth_path(conn, :signout))
    assert redirected_to(conn) == Routes.page_path(conn, :index)
    conn = get(conn, Routes.user_path(conn, :show))
    assert redirected_to(conn) == Routes.auth_path(conn, :signin)
  end
end
