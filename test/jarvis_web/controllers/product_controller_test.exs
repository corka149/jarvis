defmodule JarvisWeb.ProductControllerTest do
  alias Jarvis.ShoppingListsRepo

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

  def fixture(:product) do
    group = gen_test_data(:user_group)
    user = group.user

    {:ok, shopping_list} =
      ShoppingListsRepo.create_shopping_list(@valid_attrs_shopping_list, group)

    {:ok, product} = ShoppingListsRepo.create_product(@create_attrs, shopping_list)
    {product, shopping_list, group, user}
  end

  defp create_product(_) do
    {product, shopping_list, _group, user} = fixture(:product)
    {:ok, product: product, shopping_list: shopping_list, user: user}
  end

  # ===== TESTS =====

  describe "index" do
    setup [:create_product]

    test "lists all products", %{conn: conn, user: user, shopping_list: shopping_list} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.product_path(conn, :index, shopping_list.id))

      assert redirected_to(conn) == Routes.product_path(conn, :new, shopping_list.id)
    end
  end

  describe "create product" do
    setup [:create_product]

    test "show new form", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list
    } do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.product_path(conn, :new, shopping_list.id))

      assert html_response(conn, 200) =~ "Shopping list for"
      assert html_response(conn, 200) =~ Date.to_string(shopping_list.planned_for)
      assert html_response(conn, 200) =~ "name=\"product[name]\""
      assert html_response(conn, 200) =~ "name=\"product[amount]\""
    end

    test "use valid attrs for creating product", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list
    } do
      route = Routes.product_path(conn, :create, shopping_list.id)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.product_path(conn, :new, shopping_list.id))

      conn = post(conn, route, product: @create_attrs)
      assert redirected_to(conn) =~ route

      conn = get(conn, Routes.product_path(conn, :new, shopping_list.id))
      assert html_response(conn, 200) =~ @create_attrs.name
      assert html_response(conn, 200) =~ Integer.to_string(@create_attrs.amount)
    end

    test "use invalid attrs for creating product and expect error", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list
    } do
      route = Routes.product_path(conn, :create, shopping_list.id)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> post(route, product: @invalid_attrs)

      assert html_response(conn, 400) =~ "is invalid"
      assert html_response(conn, 400) =~ "can&#39;t be blank"
    end
  end

  describe "update product" do
    setup [:create_product]

    test "render edit form", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      product: product
    } do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.product_path(conn, :edit, shopping_list.id, product))

      assert html_response(conn, 200) =~ "value=\"#{product.name}\""
      assert html_response(conn, 200) =~ "value=\"#{product.amount}\""
    end

    test "update product with valid attrs", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      product: product
    } do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> put(Routes.product_path(conn, :update, shopping_list.id, product),
          product: @update_attrs
        )

      route = Routes.product_path(conn, :new, shopping_list.id)
      assert redirected_to(conn) =~ route

      conn = get(conn, route)
      assert html_response(conn, 200) =~ @update_attrs.name
      assert html_response(conn, 200) =~ Integer.to_string(@update_attrs.amount)
    end

    test "update product with invalid attrs and expect error", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      product: product
    } do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> put(Routes.product_path(conn, :update, shopping_list.id, product),
          product: @invalid_attrs
        )

      assert html_response(conn, 400) =~ "is invalid"
      assert html_response(conn, 400) =~ "can&#39;t be blank"
    end

    test "update product without authorization and expect rejection", %{
      conn: conn,
      shopping_list: shopping_list,
      product: product
    } do
      another_user = gen_test_data(:user)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: another_user.id)
        |> put(Routes.product_path(conn, :update, shopping_list.id, product),
          product: @invalid_attrs
        )

      assert response(conn, 403) =~ "You are not allow to do this"
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "delete existing product", %{
      conn: conn,
      user: user,
      shopping_list: shopping_list,
      product: product
    } do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> delete(Routes.product_path(conn, :delete, shopping_list.id, product))

      route = Routes.product_path(conn, :new, shopping_list.id)
      assert redirected_to(conn) =~ route

      conn = get(conn, route)
      assert not (html_response(conn, 200) =~ product.name)
    end
  end
end
