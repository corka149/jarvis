defmodule JarvisWeb.InvitationControllerTest do
  alias Jarvis.Accounts

  use JarvisWeb.ConnCase
  use Plug.Test

  @create_attrs %{invitee_name: "some name"}

  @valid_attrs_group %{name: "some name"}
  @valid_attrs_user %{
    email: "some email",
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
    {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
    {_, _} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)
    user |> Jarvis.Repo.preload(:usergroups)
  end

  describe "index" do
    test "lists all invitations", %{conn: conn} do
      {_, user} = Jarvis.Accounts.create_user(@valid_attrs_user)

      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.invitation_path(conn, :index))

      assert html_response(conn, 200) =~ "Created Invitations"
      assert html_response(conn, 200) =~ "Group membership"
      assert html_response(conn, 200) =~ "Received Invitations"
    end
  end

  describe "new invitation" do
    setup [:create_invitation]

    test "renders form", %{conn: conn, user: user} do
      conn =
        init_test_session(conn, user_id: user.id)
        |> get(Routes.invitation_path(conn, :new))

      assert html_response(conn, 200) =~ "New Invitation"
    end
  end

  describe "create invitation" do
    setup [:create_invitation]

    test "redirects to show when data is valid", %{conn: conn, group: group} do
      {_, user} =
        Jarvis.Accounts.create_user(%{
          email: "some email",
          name: "Bob",
          provider: "some provider",
          token: "some token"
        })

      create_attrs = %{invitee_name: user.name, usergroup_id: group.id}

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.invitation_path(conn, :create), invitation: create_attrs)

      assert redirected_to(conn) == Routes.invitation_path(conn, :index)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user, group: group} do
      invalid_attrs = %{invitee_name: "Not existing user", usergroup_id: group.id}

      conn =
        init_test_session(conn, user_id: user.id)
        |> post(Routes.invitation_path(conn, :create), invitation: invalid_attrs)

      assert redirected_to(conn) == Routes.invitation_path(conn, :index)
    end
  end

  describe "delete invitation" do
    setup [:create_invitation]

    test "deletes chosen invitation", %{conn: conn, invitation: invitation, user: user} do
      conn =
        init_test_session(conn, user_id: user.id)
        |> delete(Routes.invitation_path(conn, :delete, invitation))

      assert redirected_to(conn) == Routes.invitation_path(conn, :index)
    end
  end

  defp create_invitation(_) do
    invitation = fixture(:invitation)
    user = fixture(:user_and_group)
    [group | _] = user.usergroups
    {:ok, invitation: invitation, user: user, group: group}
  end
end
