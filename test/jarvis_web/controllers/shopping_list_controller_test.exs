defmodule JarvisWeb.ShoppingListControllerTest do
  alias Jarvis.ShoppingLists

  import Jarvis.TestHelper

  use Plug.Test
  use JarvisWeb.ConnCase

  @create_attrs %{done: true, planned_for: ~D[2010-04-17]}
  @update_attrs %{done: false, planned_for: ~D[2011-05-18]}
  @invalid_attrs %{done: nil, planned_for: nil}

  @valid_attrs_group %{name: "some name"}
  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  def fixture(:shopping_list) do
    {:ok, user} = Jarvis.Accounts.create_user(update_with_unique_email(@valid_attrs_user))
    {_, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@create_attrs, group)
    {shopping_list, group, user}
  end

  defp create_shopping_list(_) do
    {shopping_list, group, user} = fixture(:shopping_list)
    {:ok, shopping_list: shopping_list, group: group, user: user}
  end

  describe "index" do
    test "lists all shopping_lists", %{conn: conn} do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.shopping_list_path(conn, :index))

      assert html_response(conn, 200) =~ "All shopping lists"
    end

    test "lists open shopping_lists", %{conn: conn} do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.shopping_list_path(conn, :index_open_lists))

      assert html_response(conn, 200) =~ "Open shopping lists"
    end
  end

  describe "show" do
    setup [:create_shopping_list]

    test "show a single shopping list", %{conn: conn, user: user, shopping_list: shopping_list} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.shopping_list_path(conn, :show, shopping_list))

      assert html_response(conn, 200) =~ "2010-04-17"
      assert html_response(conn, 200) =~ "checked=\"checked\""
    end

    test "show a single shopping list without authorization", %{
      conn: conn,
      shopping_list: shopping_list
    } do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.shopping_list_path(conn, :show, shopping_list))

      response(conn, 403) =~ "You are not allow to do this"
    end
  end

  describe "create shopping_list" do
    setup [:create_shopping_list]

    test "show new form", %{conn: conn, user: user} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: user.id)
        |> get(Routes.shopping_list_path(conn, :new))

      assert html_response(conn, :ok) =~ "New shopping list"
      assert html_response(conn, :ok) =~ "Done"
      assert html_response(conn, :ok) =~ "Planned for"
      assert html_response(conn, :ok) =~ "Belongs to"
    end

    test "returns shopping_list to show when data is valid", %{
      conn: conn,
      group: group,
      user: user
    } do
      create_attrs = %{
        "done" => false,
        "planned_for" => ~D[2020-04-23],
        "belongs_to" => group.id
      }

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> post(Routes.shopping_list_path(conn, :create), shopping_list: create_attrs)

      assert %{id: id} = redirected_params(conn)
      show_url = Routes.shopping_list_path(conn, :show, id)

      assert redirected_to(conn) == show_url

      conn = get(conn, show_url)
      assert html_response(conn, :ok) =~ Date.to_string(~D[2020-04-23])
      assert html_response(conn, :ok) =~ group.name
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, user: user} do
      invalid_attrs = %{"done" => nil, "planned_for" => nil, "belongs_to" => group.id}

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> post(Routes.shopping_list_path(conn, :create), shopping_list: invalid_attrs)

      assert html_response(conn, 400) =~ "<span class=\"help-block\">can&#39;t be blank</span>"
    end
  end

  describe "update shopping_list" do
    setup [:create_shopping_list]

    test "show edit form", %{conn: conn, shopping_list: shopping_list, user: user} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: user.id)
        |> get(Routes.shopping_list_path(conn, :edit, shopping_list))

      assert html_response(conn, :ok) =~ "Edit shopping list"
      assert html_response(conn, :ok) =~ "checked"
      assert html_response(conn, :ok) =~ "2010-04-17"
      assert html_response(conn, :ok) =~ "some name"
    end

    test "redirects when data is valid", %{conn: conn, shopping_list: shopping_list} do
      group = Jarvis.ShoppingLists.get_shopping_list!(shopping_list.id).usergroup
      user = Jarvis.Accounts.get_user_group!(group.id).user

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> put(Routes.shopping_list_path(conn, :update, shopping_list),
          shopping_list: @update_attrs
        )

      assert redirected_to(conn) == Routes.shopping_list_path(conn, :show, shopping_list)

      conn =
        conn
        |> get(Routes.shopping_list_path(conn, :show, shopping_list))

      html_response(conn, :ok) =~ Date.to_string(@update_attrs.planned_for)
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      shopping_list: shopping_list,
      user: user
    } do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> put(Routes.shopping_list_path(conn, :update, shopping_list),
          shopping_list: @invalid_attrs
        )

      assert html_response(conn, 400) =~ "<span class=\"help-block\">can&#39;t be blank</span>"
    end
  end

  describe "delete shopping_list" do
    setup [:create_shopping_list]

    test "deletes chosen shopping_list", %{conn: conn, shopping_list: shopping_list, user: user} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> delete(Routes.shopping_list_path(conn, :delete, shopping_list))

      assert redirected_to(conn) == Routes.shopping_list_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.shopping_list_path(conn, :show, shopping_list))
      end
    end
  end
end
