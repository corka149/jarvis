defmodule JarvisWeb.CategoryControllerTest do
  use JarvisWeb.ConnCase
  use Plug.Test

  import Jarvis.TestHelper

  alias Jarvis.Finances
  alias Jarvis.Finances.Category

  @create_attrs %{
    name: "some name"
  }
  @update_attrs %{
    name: "some updated name"
  }
  @invalid_attrs %{name: nil}

  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  def fixture(:category) do
    {:ok, creator} = Jarvis.Accounts.create_user(update_with_unique_email(@valid_attrs_user))
    {:ok, category} = Finances.create_category(@create_attrs, creator)
    category
  end

  setup %{conn: conn} do
    {:ok, creator} = Jarvis.Accounts.create_user(@valid_attrs_user)

    conn_without_auth =
      conn
      |> put_req_header("accept", "application/json")

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> Phoenix.ConnTest.init_test_session(user_id: creator.id)

    {:ok, conn: conn, conn_without_auth: conn_without_auth, creator: creator}
  end

  describe "index" do
    test "lists all categories", %{conn: conn} do
      conn = get(conn, Routes.category_path(conn, :index))
      assert json_response(conn, 200) == []
    end
  end

  describe "create category" do
    test "renders category when data is valid", %{conn: conn} do
      conn = post(conn, Routes.category_path(conn, :create), category: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.category_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.category_path(conn, :create), category: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update category" do
    setup [:create_category]

    test "renders category when data is valid", %{
      conn: conn,
      category: %Category{id: id} = category
    } do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: category.created_by)
        |> put(Routes.category_path(conn, :update, category), category: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.category_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some updated name"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: category.created_by)
        |> put(Routes.category_path(conn, :update, category), category: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete category" do
    setup [:create_category]

    test "delete chosen category", %{conn: conn, category: category} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: category.created_by)
        |> delete(Routes.category_path(conn, :delete, category))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.category_path(conn, :show, category))
      end
    end

    test "try delete chosen category without owning it", %{conn: conn, category: category} do
      conn =
        conn
        |> delete(Routes.category_path(conn, :delete, category))

      assert response(conn, 403)
    end
  end

  defp create_category(_) do
    category = fixture(:category)
    {:ok, category: category}
  end
end
