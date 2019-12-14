defmodule JarvisWeb.InvitationControllerTest do
  alias Jarvis.Accounts

  import Jarvis.TestHelper

  use JarvisWeb.ConnCase
  use Plug.Test

  @create_attrs %{invitee_email: "some name"}

  @valid_attrs_group %{name: "some name"}
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

  describe "index" do
    test "lists all invitations", %{conn: conn} do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.invitation_path(conn, :index))

      invitation_overview = json_response(conn, 200)

      assert %{
               "received_invitations" => _received_invitations,
               "created_invitations" => _created_invitations,
               "memberships" => _memberships
             } = invitation_overview
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

      create_attrs = %{invitee_email: user.name, usergroup_id: group.id}

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.invitation_path(conn, :create), invitation: create_attrs)

      response(conn, 204)
    end

    test "Invite an not existing user and get no error (security reason)",
         %{conn: conn, user: user, group: group} do
      invalid_attrs = %{invitee_email: "Not existing user", usergroup_id: group.id}

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.invitation_path(conn, :create), invitation: invalid_attrs)

      response(conn, 204)
    end
  end

  describe "delete invitation" do
    setup [:create_invitation]

    test "deletes chosen invitation", %{conn: conn, invitation: invitation, user: user} do
      conn =
        init_test_session(conn, user_id: user.id)
        |> delete(Routes.invitation_path(conn, :delete, invitation))

      response(conn, 204)
    end
  end

  describe "accept invitation" do
    setup [:create_invitation]

    test "authorized accept of invitation", %{conn: conn, invitation: invitation} do
      conn =
        init_test_session(conn, user_id: invitation.invitee_id)
        |> get(Routes.invitation_path(conn, :accept, invitation))

      response(conn, 204)
    end

    test "accept invitation of someone else and get rejection", %{
      conn: conn,
      invitation: invitation,
      user: user
    } do
      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.invitation_path(conn, :accept, invitation))

      response(conn, 403)
    end
  end

  defp create_invitation(_) do
    invitation = fixture(:invitation)
    user = fixture(:user_and_group)
    [group | _] = user.usergroups
    {:ok, invitation: invitation, user: user, group: group}
  end
end
