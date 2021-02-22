defmodule JarvisWeb.IsleControllerTest do
  use JarvisWeb.ConnCase

  alias Jarvis.AnimalXing
  alias Jarvis.AnimalXing.Isle

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  def fixture(:isle) do
    {:ok, isle} = AnimalXing.create_isle(@create_attrs)
    isle
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all isles", %{conn: conn} do
      conn = get(conn, Routes.isle_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create isle" do
    test "renders isle when data is valid", %{conn: conn} do
      conn = post(conn, Routes.isle_path(conn, :create), isle: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.isle_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.isle_path(conn, :create), isle: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update isle" do
    setup [:create_isle]

    test "renders isle when data is valid", %{conn: conn, isle: %Isle{id: id} = isle} do
      conn = put(conn, Routes.isle_path(conn, :update, isle), isle: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.isle_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, isle: isle} do
      conn = put(conn, Routes.isle_path(conn, :update, isle), isle: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete isle" do
    setup [:create_isle]

    test "deletes chosen isle", %{conn: conn, isle: isle} do
      conn = delete(conn, Routes.isle_path(conn, :delete, isle))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.isle_path(conn, :show, isle))
      end
    end
  end

  defp create_isle(_) do
    isle = fixture(:isle)
    %{isle: isle}
  end
end
