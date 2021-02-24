defmodule JarvisWeb.UserGroupApiControllerTest do
  alias Jarvis.Accounts

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
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp create_user_group(_) do
    user_group = fixture(:user_group)
    {:ok, user_group: user_group, user: user_group.user}
  end

  # ===== TESTS =====

  describe "index" do
    setup [:create_user_group]

    test "lists all usergroups", %{conn: conn, user: user} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.user_group_api_path(conn, :index))

      assert [%{"id" => _, "name" => "some name"}] = json_response(conn, 200)["data"]
    end
  end

  describe "create user_group" do
    setup [:create_user_group]
    # Not yet needed
  end

  describe "update user_group" do
    setup [:create_user_group]
    # Not yet needed
  end
end
