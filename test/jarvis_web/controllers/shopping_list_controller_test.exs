defmodule JarvisWeb.ShoppingListControllerTest do

  alias Jarvis.ShoppingLists
  use Plug.Test
  use JarvisWeb.ConnCase


  @create_attrs %{done: true, planned_for: ~D[2010-04-17]}
  @update_attrs %{done: false, planned_for: ~D[2011-05-18]}
  @invalid_attrs %{done: nil, planned_for: nil}

  @valid_attrs_group %{name: "some name"}
  @valid_attrs_user %{email: "some email", name: "some name", provider: "some provider", token: "some token"}

  def fixture(:shopping_list) do
    {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
    {_, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@create_attrs, group)
    shopping_list
  end

  describe "index" do
    test "lists all shoppinglists", %{conn: conn} do
      {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
      conn = init_test_session(conn, user_id: user.id)
              |> get(Routes.shopping_list_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Shoppinglists"
    end
  end

  describe "new shopping_list" do
    test "renders form", %{conn: conn} do
      {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
      conn = init_test_session(conn, user_id: user.id)
              |> get(Routes.shopping_list_path(conn, :new))
      assert html_response(conn, 200) =~ "New Shopping list"
    end
  end

  describe "create shopping_list" do
    test "redirects to show when data is valid", %{conn: conn} do
      {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
      conn = init_test_session(conn, user_id: user.id)
              |> post(Routes.shopping_list_path(conn, :create), shopping_list: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.shopping_list_path(conn, :show, id)

      conn = get(conn, Routes.shopping_list_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Shopping list"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
      conn = init_test_session(conn, user_id: user.id)
              |> post(Routes.shopping_list_path(conn, :create), shopping_list: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Shopping list"
    end
  end

  describe "edit shopping_list" do
    setup [:create_shopping_list]

    test "renders form for editing chosen shopping_list", %{conn: conn, shopping_list: shopping_list} do
      group = Jarvis.ShoppingLists.get_shopping_list!(shopping_list.id).usergroup
      user = Jarvis.Accounts.get_user_group!(group.id).user
      conn = init_test_session(conn, user_id: user.id)
              |> get(Routes.shopping_list_path(conn, :edit, shopping_list))
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
