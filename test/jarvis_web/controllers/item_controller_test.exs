defmodule JarvisWeb.ItemControllerTest do
  alias Jarvis.ShoppingLists

  import Jarvis.TestHelper

  use Plug.Test
  use JarvisWeb.ConnCase

  @create_attrs %{amount: 2, name: "apples"}
  @update_attrs %{amount: 5, name: "cherries"}
  @invalid_attrs %{amount: nil, name: 12_345}

  @valid_attrs_shopping_list %{
    done: true,
    planned_for: ~D[2010-04-17]
  }
  @valid_attrs_group %{name: "some name"}
  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  def fixture(:item) do
    {:ok, user} = Jarvis.Accounts.create_user(update_with_unique_email(@valid_attrs_user))
    {:ok, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)
    {:ok, shopping_list} = ShoppingLists.create_shopping_list(@valid_attrs_shopping_list, group)
    {:ok, item} = ShoppingLists.create_item(@create_attrs, shopping_list)
    {item, shopping_list, group, user}
  end

  defp create_item(_) do
    {item, shopping_list, _group, user} = fixture(:item)
    {:ok, item: item, shopping_list: shopping_list, user: user}
  end

  describe "index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, user: user, shopping_list: shopping_list} do
      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.item_path(conn, :index, shopping_list.id))

      assert redirected_to(conn) == Routes.item_path(conn, :new, shopping_list.id)
    end
  end

  describe "create item" do
    setup [:create_item]

    test "show new form", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list
    } do

      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.item_path(conn, :new, shopping_list.id))

      assert html_response(conn, 200) =~  "Shopping list for"
      assert html_response(conn, 200) =~  Date.to_string(shopping_list.planned_for)
      assert html_response(conn, 200) =~  "name=\"item[name]\""
      assert html_response(conn, 200) =~  "name=\"item[amount]\""
    end

    test "use valid attrs for creating item", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list
    } do
      route = Routes.item_path(conn, :create, shopping_list.id)

      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.item_path(conn, :new, shopping_list.id))

      conn = post(conn, route, item: @create_attrs)
      assert redirected_to(conn) =~ route

      conn = get(conn, Routes.item_path(conn, :new, shopping_list.id))
      assert html_response(conn, 200) =~ @create_attrs.name
      assert html_response(conn, 200) =~ Integer.to_string(@create_attrs.amount)
    end

    test "use invalid attrs for creating item and expect error", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list
    } do
      route = Routes.item_path(conn, :create, shopping_list.id)

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(route, item: @invalid_attrs)

      assert html_response(conn, 400) =~ "is invalid"
      assert html_response(conn, 400) =~ "can&#39;t be blank"
    end
  end

  describe "update item" do
    setup [:create_item]

    test "render edit form", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      item: item
    } do
      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.item_path(conn, :edit, shopping_list.id, item))

      assert html_response(conn, 200) =~ "value=\"#{item.name}\""
      assert html_response(conn, 200) =~ "value=\"#{item.amount}\""
    end

    test "update item with valid attrs", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      item: item
    } do
      conn =
        init_test_session(conn, user_id: user.id)
        |> put(Routes.item_path(conn, :update, shopping_list.id, item),
          item: @update_attrs
        )

      route = Routes.item_path(conn, :new, shopping_list.id)
      assert redirected_to(conn) =~ route

      conn = get(conn,  route)
      assert html_response(conn, 200) =~ @update_attrs.name
      assert html_response(conn, 200) =~ Integer.to_string(@update_attrs.amount)
    end

    test "update item with invalid attrs and expect error", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      item: item
    } do
      conn =
        init_test_session(conn, user_id: user.id)
        |> put(Routes.item_path(conn, :update, shopping_list.id, item),
          item: @invalid_attrs
        )

      assert html_response(conn, 400) =~ "is invalid"
      assert html_response(conn, 400) =~ "can&#39;t be blank"
    end

    test "update item without authorization and expect rejection", %{
      conn: conn,
      shopping_list: shopping_list,
      item: item
    } do
      {:ok, another_user} =
        Jarvis.Accounts.create_user(update_with_unique_email(@valid_attrs_user))

      conn =
        init_test_session(conn, user_id: another_user.id)
        |> put(Routes.item_path(conn, :update, shopping_list.id, item),
          item: @invalid_attrs
        )

      assert response(conn, 403) =~ "You are not allow to do this"
    end
  end

  describe "delete item" do
    setup [:create_item]

    test "delete existing item", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      item: item
    } do
      conn =
        init_test_session(conn, user_id: user.id)
        |> delete(Routes.item_path(conn, :delete, shopping_list.id, item))

      route = Routes.item_path(conn, :new, shopping_list.id)
      assert redirected_to(conn) =~ route

      conn = get(conn, route)
      assert not(html_response(conn, 200) =~ item.name)
    end
  end
end
