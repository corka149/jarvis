defmodule JarvisWeb.UserGroupControllerTest do
  alias Jarvis.Accounts

  import Jarvis.TestHelper

  use JarvisWeb.ConnCase
  use Plug.Test

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  @valid_attrs_invitation %{invitee_email: "Alice"}

  def fixture(:user_group) do
    {:ok, user} =
      update_with_unique_email(@valid_attrs_user)
      |> Jarvis.Accounts.create_user()

    {:ok, user_group} = Accounts.create_user_group(@create_attrs, user)

    user_group
    |> Jarvis.Repo.preload(:user)
  end

  def fixture(:invitation) do
    {:ok, host} =
      %{
        email: "someemail@test.xyz",
        name: "Bob",
        provider: "some provider",
        token: "some token",
        default_language: "en"
      }
      |> update_with_unique_email()
      |> Accounts.create_user()

    {:ok, invitee} =
      %{
        email: "someemail@test.xyz",
        name: "Alice",
        provider: "some provider",
        token: "some token",
        default_language: "en"
      }
      |> update_with_unique_email()
      |> Accounts.create_user()

    {:ok, user_group} = Accounts.create_user_group(%{name: "some name"}, host)

    {:ok, invitation} =
      %{}
      |> Enum.into(@valid_attrs_invitation)
      |> Accounts.create_invitation(user_group, host, invitee)

    %{invitation: invitation, host: host, invitee: invitee}
  end

  # ===== TESTS =====

  describe "index" do
    setup [:create_user_group]

    test "lists all usergroups", %{conn: conn, user: user} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.user_group_path(conn, :index))

      assert html_response(conn, 200) =~ "All user groups"
      assert html_response(conn, 200) =~ "add"
    end

    test "lists all usergroups to which an user belong or owns", %{conn: conn} do
      %{invitation: invitation, invitee: invitee} = fixture(:invitation)
      invitation = Accounts.get_invitation!(invitation.id)
      {:ok, _} = Accounts.add_user_to_group(invitee, invitation.usergroup)
      {:ok, _} = Accounts.delete_invitation(invitation)
      {:ok, _user_group} = Accounts.create_user_group(%{name: "some name2"}, invitee)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: invitee.id)
        |> get(Routes.user_group_path(conn, :index, %{"by_membership" => "true"}))

      assert html_response(conn, 200) =~ ">some name2<"
      assert html_response(conn, 200) =~ ">some name<"
    end
  end

  describe "create user_group" do
    setup [:create_user_group]

    test "show new form", %{conn: conn, user: user} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: user.id)
        |> get(Routes.user_group_path(conn, :new))

      assert html_response(conn, :ok) =~ ">Name<"
      assert html_response(conn, :ok) =~ "New user group"
    end

    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: user.id)
        |> post(Routes.user_group_path(conn, :create), user_group: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      show_url = Routes.user_group_path(conn, :show, id)

      assert redirected_to(conn) == show_url

      conn = get(conn, show_url)
      assert html_response(conn, 200) =~ ">some name<"
      assert html_response(conn, 200) =~ "edit"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> post(Routes.user_group_path(conn, :create), user_group: @invalid_attrs)

      assert html_response(conn, 400) =~ "can&#39;t be blank"
    end
  end

  describe "update user_group" do
    setup [:create_user_group]

    test "show edit form", %{conn: conn, user_group: user_group, user: user} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: user.id)
        |> get(Routes.user_group_path(conn, :edit, user_group))

      assert html_response(conn, :ok) =~ "Edit user group"
      assert html_response(conn, :ok) =~ "value=\"some name\""
    end

    test "return updated user group when data is valid", %{
      conn: conn,
      user_group: user_group,
      user: user
    } do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: user.id)
        |> put(Routes.user_group_path(conn, :update, user_group), user_group: @update_attrs)

      show_url = Routes.user_group_path(conn, :show, user_group)
      assert redirected_to(conn) == show_url

      conn = get(conn, show_url)

      assert html_response(conn, :ok) =~ "User group"
      assert html_response(conn, :ok) =~ ">some updated name<"
    end

    test "renders errors when data is invalid", %{conn: conn, user_group: user_group, user: user} do
      conn =
        conn
        |> Phoenix.ConnTest.init_test_session(user_id: user.id)
        |> put(Routes.user_group_path(conn, :update, user_group), user_group: @invalid_attrs)

      assert html_response(conn, 400) =~ "can&#39;t be blank"
    end
  end

  describe "delete user_group" do
    setup [:create_user_group]

    test "deletes chosen user_group", %{conn: conn, user_group: user_group, user: user} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> delete(Routes.user_group_path(conn, :delete, user_group))

      assert redirected_to(conn) =~ Routes.user_group_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_group_path(conn, :show, user_group))
      end
    end
  end

  defp create_user_group(_) do
    user_group = fixture(:user_group)
    {:ok, user_group: user_group, user: user_group.user}
  end
end
