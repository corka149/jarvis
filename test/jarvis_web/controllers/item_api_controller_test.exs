defmodule JarvisWeb.ItemApiControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.Inventory
  alias Jarvis.Inventory.Item
  alias Jarvis.Inventory.Place

  import Jarvis.TestHelper

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  @valid_attrs_place %{name: "some name"}

  def fixture(:item) do
    user_group = gen_test_data(:user_group)
    {:ok, place} = Inventory.create_place(@valid_attrs_place, user_group)

    {:ok, item} = Inventory.create_item(@create_attrs, place)
    item
  end

  def fixture(:place) do
    user_group = gen_test_data(:user_group)
    {:ok, place} = Inventory.create_place(@valid_attrs_place, user_group)
    place
  end

  setup %{conn: conn} do
    place = fixture(:place)
    user = gen_test_data(:user)

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(user_id: user.id)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, place: place}
  end

  defp create_item(_) do
    item = fixture(:item)
    %{item: item}
  end

  # ===== TESTS =====

  describe "index" do
    test "lists all items", %{conn: conn, place: %Place{id: place_id}} do
      conn = get(conn, Routes.item_api_path(conn, :index, place_id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create item" do
    test "renders item when data is valid", %{conn: conn, place: %Place{id: place_id}} do
      conn = post(conn, Routes.item_api_path(conn, :create, place_id), item: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.item_api_path(conn, :show, place_id, id))

      assert %{
               "id" => _,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, place: %Place{id: place_id}} do
      conn = post(conn, Routes.item_api_path(conn, :create, place_id), item: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update item" do
    setup [:create_item]

    test "renders item when data is valid", %{
      conn: conn,
      item: %Item{id: id} = item,
      place: %Place{id: place_id}
    } do
      conn = put(conn, Routes.item_api_path(conn, :update, place_id, item), item: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.item_api_path(conn, :show, place_id, id))

      assert %{
               "id" => _,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      item: item,
      place: %Place{id: place_id}
    } do
      conn = put(conn, Routes.item_api_path(conn, :update, place_id, item), item: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete item" do
    setup [:create_item]

    test "deletes chosen item", %{conn: conn, item: item, place: %Place{id: place_id}} do
      conn = delete(conn, Routes.item_api_path(conn, :delete, place_id, item))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.item_api_path(conn, :show, place_id, item))
      end
    end
  end
end
