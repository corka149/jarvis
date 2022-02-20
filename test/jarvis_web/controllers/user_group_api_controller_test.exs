defmodule JarvisWeb.UserGroupApiControllerTest do
  alias Jarvis.Repo.Accounts

  import Jarvis.TestHelper

  use JarvisWeb.ConnCase
  use Plug.Test

  @create_attrs %{name: "some name"}

  def fixture(:user_group) do
    user = gen_test_data(:user)

    {:ok, user_group} = Accounts.create_user_group(@create_attrs, user)

    user_group
    |> Jarvis.Repo.preload(:user)
  end

  setup %{conn: conn} do
    user_group = fixture(:user_group)

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(user_id: user_group.user.id)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn, user_group: user_group, user: user_group.user}
  end

  # ===== TESTS =====

  describe "index" do
    test "lists all usergroups", %{conn: conn} do
      conn = get(conn, Routes.user_group_api_path(conn, :index))

      assert [%{"id" => _, "name" => "some name"}] = json_response(conn, 200)["data"]
    end
  end

  describe "create user_group" do
    # Not yet needed
  end

  describe "update user_group" do
    # Not yet needed
  end
end
