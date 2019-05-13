defmodule JarvisWeb.ShoppingListControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.ShoppingLists

  @create_attrs %{done: true, planned_for: ~D[2010-04-17]}
  @update_attrs %{done: false, planned_for: ~D[2011-05-18]}
  @invalid_attrs %{done: nil, planned_for: nil}

  def fixture(:shopping_list) do
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@create_attrs)
    shopping_list
  end

  describe "index" do
    test "lists all shoppinglists", %{conn: conn} do
      conn = get(conn, Routes.shopping_list_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Shoppinglists"
    end
  end

  describe "new shopping_list" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.shopping_list_path(conn, :new))
      assert html_response(conn, 200) =~ "New Shopping list"
    end
  end

  describe "create shopping_list" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.shopping_list_path(conn, :create), shopping_list: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.shopping_list_path(conn, :show, id)

      conn = get(conn, Routes.shopping_list_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Shopping list"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.shopping_list_path(conn, :create), shopping_list: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Shopping list"
    end
  end

  describe "edit shopping_list" do
    setup [:create_shopping_list]

    test "renders form for editing chosen shopping_list", %{conn: conn, shopping_list: shopping_list} do
      conn = get(conn, Routes.shopping_list_path(conn, :edit, shopping_list))
      assert html_response(conn, 200) =~ "Edit Shopping list"
    end
  end

  describe "update shopping_list" do
    setup [:create_shopping_list]

    test "redirects when data is valid", %{conn: conn, shopping_list: shopping_list} do
      conn = put(conn, Routes.shopping_list_path(conn, :update, shopping_list), shopping_list: @update_attrs)
      assert redirected_to(conn) == Routes.shopping_list_path(conn, :show, shopping_list)

      conn = get(conn, Routes.shopping_list_path(conn, :show, shopping_list))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, shopping_list: shopping_list} do
      conn = put(conn, Routes.shopping_list_path(conn, :update, shopping_list), shopping_list: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Shopping list"
    end
  end

  describe "delete shopping_list" do
    setup [:create_shopping_list]

    test "deletes chosen shopping_list", %{conn: conn, shopping_list: shopping_list} do
      conn = delete(conn, Routes.shopping_list_path(conn, :delete, shopping_list))
      assert redirected_to(conn) == Routes.shopping_list_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.shopping_list_path(conn, :show, shopping_list))
      end
    end
  end

  defp create_shopping_list(_) do
    shopping_list = fixture(:shopping_list)
    {:ok, shopping_list: shopping_list}
  end
end