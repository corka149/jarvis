defmodule JarvisWeb.UserControllerTest do
  use JarvisWeb.ConnCase
  use Plug.Test

  import Jarvis.TestHelper

  alias Jarvis.Accounts.User

  @create_attrs %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "dummy",
    token: "dummy",
    password: "THIS_15_password"
  }
  @update_attrs %{
    email: "someupdatedemail@test.xyz",
    name: "some updated name"
  }
  @invalid_attrs %{
    email: "someemail@test.xyz",
    name: nil
  }

  def fixture(:user) do
    {:ok, user} =
      update_with_unique_email(@create_attrs)
      |> Jarvis.Accounts.create_user()

    user
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{} = user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> put(Routes.user_path(conn, :update), user: @update_attrs)

      assert redirected_to(conn) == Routes.user_path(conn, :show)

      conn = get(conn, Routes.user_path(conn, :show))

      assert response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> put(Routes.user_path(conn, :update), user: @invalid_attrs)

      assert response(conn, 400) =~ "save"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "delete user with authorization", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> delete(Routes.user_path(conn, :delete))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
