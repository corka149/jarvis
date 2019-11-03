defmodule JarvisWeb.UserControllerTest do
  use JarvisWeb.ConnCase
  use Plug.Test

  alias Jarvis.Accounts.User

  @create_attrs %{
    email: "some email",
    name: "some name"
  }
  @update_attrs %{
    email: "some updated email",
    name: "some updated name"
  }
  @invalid_attrs %{
    email: "some email",
    name: nil
  }

  def fixture(:user) do
    create_attrs = @create_attrs
                    |> Map.put(:provider, "dummy")
                    |> Map.put(:token, "dummy")
    {:ok, user} = Jarvis.Accounts.create_user(create_attrs)
    user
  end

  setup %{conn: conn} do
    conn = conn
            |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      resp_conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(resp_conn, 201)

      conn = conn
              |> init_test_session(user_id: id)
              |> get(Routes.user_path(conn, :show, id))

      assert %{
        "id" => id,
        "name" => "some name"
      } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = conn
              |> init_test_session(user_id: user.id)
              |> put(Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
        "id" => id,
        "name" => "some updated name"
      } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = conn
              |> init_test_session(user_id: user.id)
              |> put(Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "delete user with authorization", %{conn: conn, user: user} do
      conn = conn
              |> init_test_session(user_id: user.id)
              |> delete(Routes.user_path(conn, :delete, user))
      response conn, 204
    end

    test "delete user without authorization", %{conn: conn, user: user} do
      requester = fixture(:user)
      conn = conn
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
