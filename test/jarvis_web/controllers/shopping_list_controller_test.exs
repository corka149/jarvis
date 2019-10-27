defmodule JarvisWeb.ShoppingListControllerTest do
  alias Jarvis.ShoppingLists
  use Plug.Test
  use JarvisWeb.ConnCase

  @create_attrs %{done: true, planned_for: ~D[2010-04-17]}
  @update_attrs %{done: false, planned_for: ~D[2011-05-18]}
  @invalid_attrs %{done: nil, planned_for: nil}

  @valid_attrs_group %{name: "some name"}
  @valid_attrs_user %{
    email: "some email",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  def fixture(:shopping_list) do
    {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
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
      {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.shopping_list_path(conn, :index))

      shoppinglists = json_response(conn, 200)
      assert is_list(shoppinglists)
    end
  end

  describe "show shopping_list" do
    setup [:create_shopping_list]

    test "show a single shopping list", %{conn: conn, user: user, shopping_list: shopping_list} do
      conn = init_test_session(conn, user_id: user.id)
             |> get(Routes.shopping_list_path(conn, :show, shopping_list))
      response_shopping_list = json_response(conn, 200)

      assert shopping_list = response_shopping_list
    end
  end

  describe "create shopping_list" do
    setup [:create_shopping_list]

    test "returns shopping_list to show when data is valid", %{
      conn: conn,
      group: group,
      user: user
    } do
      create_attrs = %{
        "done" => false,
        "planned_for" => DateTime.utc_now(),
        "belongs_to" => group.id
      }

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.shopping_list_path(conn, :create), shopping_list: create_attrs)

      new_shoppinglist = json_response(conn, 201)
      assert create_attrs = new_shoppinglist
    end

    test "renders errors when data is invalid", %{conn: conn, group: group, user: user} do
      invalid_attrs = %{"done" => nil, "planned_for" => nil, "belongs_to" => group.id}

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.shopping_list_path(conn, :create), shopping_list: invalid_attrs)

      error_msg = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "done" => ["can't be blank"],
                 "planned_for" => ["can't be blank"]
               }
             } = error_msg
    end
  end

  describe "update shopping_list" do
    setup [:create_shopping_list]

    test "redirects when data is valid", %{conn: conn, shopping_list: shopping_list} do
      group = Jarvis.ShoppingLists.get_shopping_list!(shopping_list.id).usergroup
      user = Jarvis.Accounts.get_user_group!(group.id).user

      conn =
        init_test_session(conn, user_id: user.id)
        |> put(Routes.shopping_list_path(conn, :update, shopping_list),
          shopping_list: @update_attrs
        )

      update_shoppinglist = json_response(conn, 200)
      assert %{"done" => false, "planned_for" => "2011-05-18"} = update_shoppinglist
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      shopping_list: shopping_list,
      user: user
    } do
      conn =
        init_test_session(conn, user_id: user.id)
        |> put(Routes.shopping_list_path(conn, :update, shopping_list),
          shopping_list: @invalid_attrs
        )

      error_msg = json_response(conn, 422)

      assert %{"errors" => %{"done" => ["can't be blank"], "planned_for" => ["can't be blank"]}} =
               error_msg
    end
  end

  describe "delete shopping_list" do
    setup [:create_shopping_list]

    test "deletes chosen shopping_list", %{conn: conn, shopping_list: shopping_list, user: user} do
      conn =
        init_test_session(conn, user_id: user.id)
        |> delete(Routes.shopping_list_path(conn, :delete, shopping_list))

      response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.shopping_list_path(conn, :show, shopping_list))
      end
    end
  end
end
