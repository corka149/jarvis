defmodule JarvisWeb.UserControllerTest do
  use JarvisWeb.ConnCase
  use Plug.Test

  import Jarvis.TestHelper

  alias Jarvis.Accounts.User
  alias Jarvis.Accounts

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

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "ZWQ1ZmE5ZmEtZmI0NS00YjJiLWJhMDQtY2YwNjQ0ODcwNzQ0")
      resp_conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"name" => name} = json_response(resp_conn, 201)
      %{id: id} = Accounts.get_user_by_name(name)

      conn =
        conn
        |> init_test_session(user_id: id)
        |> get(Routes.user_path(conn, :show, id))

      assert %{
               "name" => "some name"
             } = json_response(conn, 200)
    end

    test "renders errors when request is without authorization", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      response(conn, 403) =~ "You are not allow to do this"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = put_req_header(conn, "authorization", "ZWQ1ZmE5ZmEtZmI0NS00YjJiLWJhMDQtY2YwNjQ0ODcwNzQ0")
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> put(Routes.user_path(conn, :update, user), user: @update_attrs)

      assert %{"name" => _} = json_response(conn, 200)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "name" => "some updated name"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> put(Routes.user_path(conn, :update, user), user: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "delete user with authorization", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_id: user.id)
        |> delete(Routes.user_path(conn, :delete, user))

      response(conn, 204)
    end

    test "delete user without authorization", %{conn: conn, user: user} do
      requester = fixture(:user)

      conn =
        conn
        |> init_test_session(user_id: requester.id)
        |> delete(Routes.user_path(conn, :delete, user))

      response(conn, 403) =~ "You are not allow to do this"
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
