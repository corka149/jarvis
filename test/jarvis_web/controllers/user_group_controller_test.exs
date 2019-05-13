defmodule JarvisWeb.UserGroupControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.Accounts

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:user_group) do
    {:ok, user_group} = Accounts.create_user_group(@create_attrs)
    user_group
  end

  describe "index" do
    test "lists all usergroups", %{conn: conn} do
      conn = get(conn, Routes.user_group_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Usergroups"
    end
  end

  describe "new user_group" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_group_path(conn, :new))
      assert html_response(conn, 200) =~ "New User group"
    end
  end

  describe "create user_group" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_group_path(conn, :create), user_group: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_group_path(conn, :show, id)

      conn = get(conn, Routes.user_group_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User group"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_group_path(conn, :create), user_group: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User group"
    end
  end

  describe "edit user_group" do
    setup [:create_user_group]

    test "renders form for editing chosen user_group", %{conn: conn, user_group: user_group} do
      conn = get(conn, Routes.user_group_path(conn, :edit, user_group))
      assert html_response(conn, 200) =~ "Edit User group"
    end
  end

  describe "update user_group" do
    setup [:create_user_group]

    test "redirects when data is valid", %{conn: conn, user_group: user_group} do
      conn = put(conn, Routes.user_group_path(conn, :update, user_group), user_group: @update_attrs)
      assert redirected_to(conn) == Routes.user_group_path(conn, :show, user_group)

      conn = get(conn, Routes.user_group_path(conn, :show, user_group))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user_group: user_group} do
      conn = put(conn, Routes.user_group_path(conn, :update, user_group), user_group: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User group"
    end
  end

  describe "delete user_group" do
    setup [:create_user_group]

    test "deletes chosen user_group", %{conn: conn, user_group: user_group} do
      conn = delete(conn, Routes.user_group_path(conn, :delete, user_group))
      assert redirected_to(conn) == Routes.user_group_path(conn, :index)
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