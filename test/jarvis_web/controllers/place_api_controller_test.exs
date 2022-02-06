defmodule JarvisWeb.PlaceApiControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.Inventory
  alias Jarvis.Inventory.Place

  import Jarvis.TestHelper

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:place) do
    user_group = gen_test_data(:user_group)

    {:ok, place} = Inventory.create_place(@create_attrs, user_group)
    place
  end

  setup %{conn: conn} do
    user = gen_test_data(:user)

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(user_id: user.id)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  defp create_place(_) do
    place = fixture(:place)
    %{place: place}
  end

  # ===== TESTS =====

  describe "index" do
    test "lists all places", %{conn: conn} do
      conn = get(conn, Routes.place_api_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create place" do
    test "renders place when data is valid", %{conn: conn} do
      user_group = gen_test_data(:user_group)
      create_attrs = Map.put(@create_attrs, :owned_by, user_group.id)

      conn = post(conn, Routes.place_api_path(conn, :create), place: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.place_api_path(conn, :show, id))

      assert %{
               "id" => _,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user_group = gen_test_data(:user_group)
      invalid_attrs = Map.put(@invalid_attrs, :owned_by, user_group.id)

      conn = post(conn, Routes.place_api_path(conn, :create), place: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update place" do
    setup [:create_place]

    test "renders place when data is valid", %{conn: conn, place: %Place{id: id} = place} do
      conn = put(conn, Routes.place_api_path(conn, :update, place), place: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.place_api_path(conn, :show, id))

      assert %{
               "id" => _,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, place: place} do
      conn = put(conn, Routes.place_api_path(conn, :update, place), place: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete place" do
    setup [:create_place]

    test "deletes chosen place", %{conn: conn, place: place} do
      conn = delete(conn, Routes.place_api_path(conn, :delete, place))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.place_api_path(conn, :show, place))
      end
    end
  end
end
