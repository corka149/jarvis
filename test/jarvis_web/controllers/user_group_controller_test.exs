defmodule JarvisWeb.UserGroupControllerTest do
  alias Jarvis.Accounts

  import Jarvis.TestHelper

  use JarvisWeb.ConnCase
  use Plug.Test

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  def fixture(:user_group) do
    {:ok, user} = update_with_unique_email(@valid_attrs_user)
                  |>Jarvis.Accounts.create_user()
    {:ok, user_group} = Accounts.create_user_group(@create_attrs, user)

    user_group
    |> Jarvis.Repo.preload(:user)
  end

  describe "index" do
    test "lists all usergroups", %{conn: conn} do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.user_group_path(conn, :index))

      groups = json_response(conn, 200)
      assert is_list(groups)
    end
  end

  describe "create user_group" do
    test "redirects to show when data is valid", %{conn: conn} do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.user_group_path(conn, :create), user_group: @create_attrs)

      assert %{"id" => _id, "name" => _name} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.user_group_path(conn, :create), user_group: @invalid_attrs)

      response_body = json_response(conn, 422)
      assert %{"errors" => %{"name" => ["can't be blank"]}} = response_body
    end
  end

  describe "update user_group" do
    setup [:create_user_group]

    test "return updated user group when data is valid", %{conn: conn, user_group: user_group} do
      conn =
        init_test_session(conn, user_id: user_group.user.id)
        |> put(Routes.user_group_path(conn, :update, user_group), user_group: @update_attrs)

      update_group = json_response(conn, 200)
      assert %{"id" => _id, "name" => "some updated name"} = update_group
    end

    test "renders errors when data is invalid", %{conn: conn, user_group: user_group} do
      conn =
        init_test_session(conn, user_id: user_group.user.id)
        |> put(Routes.user_group_path(conn, :update, user_group), user_group: @invalid_attrs)

      response_body = json_response(conn, 422)
      assert %{"errors" => %{"name" => ["can't be blank"]}} = response_body
    end
  end

  describe "delete user_group" do
    setup [:create_user_group]

    test "deletes chosen user_group", %{conn: conn, user_group: user_group} do
      conn =
        init_test_session(conn, user_id: user_group.user.id)
        |> delete(Routes.user_group_path(conn, :delete, user_group))

      assert response(conn, 204) == ""

      assert_error_sent 404, fn ->
        get(conn, Routes.user_group_path(conn, :show, user_group))
      end
    end
  end

  defp create_user_group(_) do
    user_group = fixture(:user_group)
    {:ok, user_group: user_group}
  end
end
