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

      items = json_response(conn, 200)
      assert is_list(items)
    end
  end

  describe "show" do
    setup [:create_item]

    test "show item", %{conn: conn, shopping_list: shopping_list, item: item, user: user} do
      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.item_path(conn, :show, shopping_list.id, item))

      response_item = json_response(conn, 200)

      assert %{"amount" => 2, "id" => _id, "name" => "apples"} = response_item,
             "Responsed item is not in original item"
    end
  end

  describe "create item" do
    setup [:create_item]

    test "use valid attrs for creating item", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list
    } do
      route = Routes.item_path(conn, :create, shopping_list.id)

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(route, item: @create_attrs)

      create_item = json_response(conn, 201)

      assert %{"amount" => 2, "id" => _id, "name" => "apples"} = create_item
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

      error_msg = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "amount" => ["can't be blank"],
                 "name" => ["is invalid"]
               }
             } = error_msg
    end
  end

  describe "update item" do
    setup [:create_item]

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

      update_item = json_response(conn, 200)
      assert %{"amount" => 5, "id" => _id, "name" => "cherries"} = update_item
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

      update_item = json_response(conn, 422)

      assert %{
               "errors" => %{
                 "amount" => ["can't be blank"],
                 "name" => ["is invalid"]
               }
             } = update_item
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

      response(conn, 204)
    end
  end
end
