defmodule JarvisWeb.InvitationControllerTest do
  alias Jarvis.Accounts

  import Jarvis.TestHelper

  use JarvisWeb.ConnCase
  use Plug.Test

  @create_attrs %{invitee_email: "some name"}

  @valid_attrs_group %{name: "some group name"}
  @valid_attrs_user %{
    email: "someemail@test.xyz",
    name: "some name",
    provider: "some provider",
    token: "some token"
  }

  def fixture(:invitation) do
    user = fixture(:user_and_group)
    [group | _] = user.usergroups
    {:ok, invitation} = Accounts.create_invitation(@create_attrs, group, user, user)
    invitation
  end

  def fixture(:user_and_group) do
    {:ok, user} = Jarvis.Accounts.create_user(update_with_unique_email(@valid_attrs_user))
    {:ok, _} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)
    user |> Jarvis.Repo.preload(:usergroups)
  end

  defp create_invitation(_) do
    invitation = fixture(:invitation)
    user = fixture(:user_and_group)
    [group | _] = user.usergroups
    {:ok, invitation: invitation, user: user, group: group}
  end

  # ===== TESTS =====

  describe "index" do
    test "lists all invitations", %{conn: conn} do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.invitation_path(conn, :index))

      assert html_response(conn, 200) =~ "Created invitations"
      assert html_response(conn, 200) =~ "Received invitations"
      assert html_response(conn, 200) =~ "Group memberships"
    end
  end

  describe "create invitation" do
    setup [:create_invitation]

    test "redirects to show when data is valid", %{conn: conn, group: group} do
      {_, user} =
        Jarvis.Accounts.create_user(%{
          email: "someemail@test.xyz",
          name: "Bob",
          provider: "some provider",
          token: "some token"
        })

      create_attrs = %{invitee_email: user.email, usergroup_id: group.id}

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: group.user_id)
        |> post(Routes.invitation_path(conn, :create), invitation: create_attrs)

      show_url = Routes.invitation_path(conn, :index)
      assert redirected_to(conn) == show_url

      conn = get(conn, show_url)
      assert html_response(conn, 200) =~ user.email
      assert html_response(conn, 200) =~ group.name
    end

    test "Invite an not existing user and get no error (security reason)",
         %{conn: conn, user: user, group: group} do
      invalid_attrs = %{invitee_email: "Not existing user", usergroup_id: group.id}

      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> post(Routes.invitation_path(conn, :create), invitation: invalid_attrs)

      assert redirected_to(conn) == Routes.invitation_path(conn, :index)
    end
  end

  describe "delete invitation" do
    setup [:create_invitation]

    test "deletes chosen invitation", %{conn: conn, invitation: invitation, user: user} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> delete(Routes.invitation_path(conn, :delete, invitation))

      assert redirected_to(conn) == Routes.invitation_path(conn, :index)
    end
  end

  describe "accept invitation" do
    setup [:create_invitation]

    test "authorized accept of invitation", %{conn: conn, invitation: invitation} do
      conn = Phoenix.ConnTest.init_test_session(conn, user_id: invitation.invitee_id)
      index_url = Routes.invitation_path(conn, :index)
      host = Accounts.get_user!(invitation.host_id)

      conn = get(conn, index_url)
      assert html_response(conn, 200) =~ host.name

      conn = get(conn, Routes.invitation_path(conn, :accept, invitation))

      assert redirected_to(conn) == index_url
      conn = get(conn, index_url)
      assert not (html_response(conn, 200) =~ host.name)
    end

    test "authorized accept of two invitations", %{conn: conn, invitation: invitation} do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: invitation.invitee_id)
        |> get(Routes.invitation_path(conn, :accept, invitation))

      user = fixture(:user_and_group)
      [group | _] = user.usergroups
      {:ok, invitation} = Accounts.create_invitation(@create_attrs, group, user, user)

      conn =
        conn
        |> recycle()
        |> Phoenix.ConnTest.init_test_session(user_id: invitation.invitee_id)
        |> get(Routes.invitation_path(conn, :accept, invitation))

      assert redirected_to(conn) == Routes.invitation_path(conn, :index)
    end

    test "accept invitation of someone else and get rejection", %{
      conn: conn,
      invitation: invitation,
      user: user
    } do
      conn =
        Phoenix.ConnTest.init_test_session(conn, user_id: user.id)
        |> get(Routes.invitation_path(conn, :accept, invitation))

      response(conn, 403)
    end
  end
end
