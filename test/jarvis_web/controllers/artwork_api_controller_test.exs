defmodule JarvisWeb.ArtworkApiControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Artwork
  alias Jarvis.AnimalXing.Isle

  import Jarvis.TestHelper

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  @valid_attrs_isle %{name: "some name"}

  def fixture(:artwork) do
    user_group = gen_test_data(:user_group)
    {:ok, isle} = AnimalXing.create_isle(@valid_attrs_isle, user_group)

    {:ok, artwork} = AnimalXing.create_artwork(@create_attrs, isle)
    artwork
  end

  def fixture(:isle) do
    user_group = gen_test_data(:user_group)
    {:ok, isle} = AnimalXing.create_isle(@valid_attrs_isle, user_group)
    isle
  end

  setup %{conn: conn} do
    isle = fixture(:isle)

    {:ok, conn: put_req_header(conn, "accept", "application/json"), isle: isle}
  end

  defp create_artwork(_) do
    artwork = fixture(:artwork)
    %{artwork: artwork}
  end

  # ===== TESTS =====

  describe "index" do
    test "lists all artworks", %{conn: conn, isle: %Isle{id: isle_id}} do
      conn = get(conn, Routes.artwork_api_path(conn, :index, isle_id))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create artwork" do
    test "renders artwork when data is valid", %{conn: conn, isle: %Isle{id: isle_id}} do
      conn = post(conn, Routes.artwork_api_path(conn, :create, isle_id), artwork: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.artwork_api_path(conn, :show, isle_id, id))

      assert %{
               "id" => _,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, isle: %Isle{id: isle_id}} do
      conn = post(conn, Routes.artwork_api_path(conn, :create, isle_id), artwork: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update artwork" do
    setup [:create_artwork]

    test "renders artwork when data is valid", %{
      conn: conn,
      artwork: %Artwork{id: id} = artwork,
      isle: %Isle{id: isle_id}
    } do
      conn =
        put(conn, Routes.artwork_api_path(conn, :update, isle_id, artwork), artwork: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.artwork_api_path(conn, :show, isle_id, id))

      assert %{
               "id" => _,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      artwork: artwork,
      isle: %Isle{id: isle_id}
    } do
      conn =
        put(conn, Routes.artwork_api_path(conn, :update, isle_id, artwork),
          artwork: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete artwork" do
    setup [:create_artwork]

    test "deletes chosen artwork", %{conn: conn, artwork: artwork, isle: %Isle{id: isle_id}} do
      conn = delete(conn, Routes.artwork_api_path(conn, :delete, isle_id, artwork))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.artwork_api_path(conn, :show, isle_id, artwork))
      end
    end
  end
end
