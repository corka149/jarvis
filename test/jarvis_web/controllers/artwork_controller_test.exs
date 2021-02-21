defmodule JarvisWeb.ArtworkControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Artwork

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:artwork) do
    {:ok, artwork} = AnimalXing.create_artwork(@create_attrs)
    artwork
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all artworks", %{conn: conn} do
      conn = get(conn, Routes.artwork_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create artwork" do
    test "renders artwork when data is valid", %{conn: conn} do
      conn = post(conn, Routes.artwork_path(conn, :create), artwork: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.artwork_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.artwork_path(conn, :create), artwork: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update artwork" do
    setup [:create_artwork]

    test "renders artwork when data is valid", %{conn: conn, artwork: %Artwork{id: id} = artwork} do
      conn = put(conn, Routes.artwork_path(conn, :update, artwork), artwork: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.artwork_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, artwork: artwork} do
      conn = put(conn, Routes.artwork_path(conn, :update, artwork), artwork: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete artwork" do
    setup [:create_artwork]

    test "deletes chosen artwork", %{conn: conn, artwork: artwork} do
      conn = delete(conn, Routes.artwork_path(conn, :delete, artwork))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.artwork_path(conn, :show, artwork))
      end
    end
  end

  defp create_artwork(_) do
    artwork = fixture(:artwork)
    %{artwork: artwork}
  end
end
