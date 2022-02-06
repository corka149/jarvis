defmodule JarvisWeb.ArtworkApiControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.Inventory
  alias Jarvis.Inventory.Artwork
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

  def fixture(:artwork) do
    user_group = gen_test_data(:user_group)
    {:ok, place} = Inventory.create_place(@valid_attrs_place, user_group)

    {:ok, artwork} = Inventory.create_artwork(@create_attrs, place)
    artwork
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

  defp create_artwork(_) do
    artwork = fixture(:artwork)
    %{artwork: artwork}
  end

  # ===== TESTS =====

  describe "index" do
    test "lists all artworks", %{conn: conn, place: %Place{id: place_id}} do
      conn = get(conn, Routes.artwork_api_path(conn, :index, place_id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create artwork" do
    test "renders artwork when data is valid", %{conn: conn, place: %Place{id: place_id}} do
      conn = post(conn, Routes.artwork_api_path(conn, :create, place_id), artwork: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.artwork_api_path(conn, :show, place_id, id))

      assert %{
               "id" => _,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, place: %Place{id: place_id}} do
      conn = post(conn, Routes.artwork_api_path(conn, :create, place_id), artwork: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update artwork" do
    setup [:create_artwork]

    test "renders artwork when data is valid", %{
      conn: conn,
      artwork: %Artwork{id: id} = artwork,
      place: %Place{id: place_id}
    } do
      conn =
        put(conn, Routes.artwork_api_path(conn, :update, place_id, artwork), artwork: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.artwork_api_path(conn, :show, place_id, id))

      assert %{
               "id" => _,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      artwork: artwork,
      place: %Place{id: place_id}
    } do
      conn =
        put(conn, Routes.artwork_api_path(conn, :update, place_id, artwork),
          artwork: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete artwork" do
    setup [:create_artwork]

    test "deletes chosen artwork", %{conn: conn, artwork: artwork, place: %Place{id: place_id}} do
      conn = delete(conn, Routes.artwork_api_path(conn, :delete, place_id, artwork))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.artwork_api_path(conn, :show, place_id, artwork))
      end
    end
  end
end
