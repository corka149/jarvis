defmodule Jarvis.AccountsTest do
  use Jarvis.DataCase

  import Jarvis.TestHelper

  alias Jarvis.Accounts

  describe "users" do
    alias Jarvis.Accounts.User

    @valid_attrs %{
      email: "someemail@test.xyz",
      name: "some name",
      provider: "some provider",
      token: "some token",
      default_language: "en",
    }
    @update_attrs %{
      email: "someupdatedemail@test.xyz",
      name: "some updated name",
      provider: "some updated provider",
      token: "some updated token"
    }
    @invalid_attrs %{email: nil, name: nil, provider: nil, token: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> update_with_unique_email()
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user =
        user_fixture()
        |> Jarvis.Repo.preload(:member_of)
        |> Jarvis.Repo.preload(:usergroups)

      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} =  update_with_unique_email(@valid_attrs)
                                      |> Accounts.create_user()
      assert String.contains? user.email, "someemail@test.xyz"
      assert user.name == "some name"
      assert user.provider == "some provider"
      assert user.token == "some token"
    end

    test "create_user/1 with valid data creates a user for provider jarvis" do
      assert {:ok, %User{} = user} =  %{@valid_attrs | provider: "jarvis"}
                                      |> Map.put(:password, "THIS#15-password")
                                      |> update_with_unique_email()
                                      |> Accounts.create_user()
      assert String.contains? user.email, "someemail@test.xyz"
      assert user.name == "some name"
      assert user.provider == "jarvis"
      assert user.token == "some token"
    end

    test "create_user/1 for provider without password returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = %{@valid_attrs | provider: "jarvis"}
                                            |> Accounts.create_user()
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "someupdatedemail@test.xyz"
      assert user.name == "some updated name"
      assert user.provider == "some updated provider"
      assert user.token == "some updated token"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user =
        user_fixture()
        |> Jarvis.Repo.preload(:member_of)
        |> Jarvis.Repo.preload(:usergroups)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "usergroups" do
    alias Jarvis.Accounts.UserGroup

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    @valid_attrs_user %{
      email: "someemail@test.xyz",
      name: "some name",
      provider: "some provider",
      token: "some token"
    }

    def user_group_fixture(attrs \\ %{}) do
      {:ok, user} = update_with_unique_email(@valid_attrs_user)
                    |>Jarvis.Accounts.create_user()

      {:ok, user_group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_group(user)

      user_group
    end

    test "list_usergroups/0 returns all usergroups" do
      user_group = user_group_fixture()
      assert Accounts.list_usergroups() == [user_group]
    end

    test "get_user_group!/1 returns the user_group with given id" do
      user_group =
        user_group_fixture()
        |> Jarvis.Repo.preload(:user)

      assert Accounts.get_user_group!(user_group.id) == user_group
    end

    test "create_user_group/1 with valid data creates a user_group" do
      {:ok, user} = update_with_unique_email(@valid_attrs_user)
                    |>Jarvis.Accounts.create_user()
      assert {:ok, %UserGroup{} = user_group} = Accounts.create_user_group(@valid_attrs, user)
      assert user_group.name == "some name"
    end

    test "create_user_group/1 with invalid data returns error changeset" do
      {:ok, user} = Accounts.create_user(@valid_attrs_user)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_group(@invalid_attrs, user)
    end

    test "update_user_group/2 with valid data updates the user_group" do
      user_group = user_group_fixture()

      assert {:ok, %UserGroup{} = user_group} =
               Accounts.update_user_group(user_group, @update_attrs)

      assert user_group.name == "some updated name"
    end

    test "update_user_group/2 with invalid data returns error changeset" do
      user_group =
        user_group_fixture()
        |> Jarvis.Repo.preload(:user)

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_group(user_group, @invalid_attrs)
      assert user_group == Accounts.get_user_group!(user_group.id)
    end

    test "delete_user_group/1 deletes the user_group" do
      user_group = user_group_fixture()
      assert {:ok, %UserGroup{}} = Accounts.delete_user_group(user_group)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_group!(user_group.id) end
    end

    test "change_user_group/1 returns a user_group changeset" do
      user_group = user_group_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_group(user_group)
    end
  end

  describe "invitations" do
    alias Jarvis.Accounts.Invitation

    @valid_attrs %{invitee_name: "Alice"}
    @update_attrs %{}
    @invalid_attrs %{}

    def invitation_fixture(attrs \\ %{}) do
      {:ok, host} = %{
        email: "someemail@test.xyz",
        name: "Bob",
        provider: "some provider",
        token: "some token",
        default_language: "en"
      } |> update_with_unique_email()
        |> Accounts.create_user()

      {:ok, invitee} = %{
        email: "someemail@test.xyz",
        name: "Alice",
        provider: "some provider",
        token: "some token",
        default_language: "en"
      } |> update_with_unique_email()
        |> Accounts.create_user()

      {:ok, user_group} = Accounts.create_user_group(%{name: "some name"}, host)

      {:ok, invitation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_invitation(user_group, host, invitee)

      %{invitation: invitation, host: host, invitee: invitee}
    end

    test "list_invitations/0 returns all invitations" do
      %{invitation: invitation} = invitation_fixture()
      assert Accounts.list_invitations() == [invitation]
    end

    test "get_invitation!/1 returns the invitation with given id" do
      %{invitation: invitation} = invitation_fixture()

      invitation = invitation
                    |> Jarvis.Repo.preload(:host)
                    |> Jarvis.Repo.preload(:usergroup)
                    |> Jarvis.Repo.preload(:invitee)

      assert Accounts.get_invitation!(invitation.id) == invitation
    end

    test "create_invitation/1 with valid data creates a invitation" do
      %{host: host, invitee: invitee} = invitation_fixture()

      {:ok, user_group} = Accounts.create_user_group(%{name: "some name"}, host)

      assert {:ok, %Invitation{} = invitation} =
               Accounts.create_invitation(@valid_attrs, user_group, host, invitee)
    end

    test "create_invitation/1 with invalid data returns error changeset" do
      %{host: host, invitee: invitee} = invitation_fixture()

      {:ok, user_group} = Accounts.create_user_group(%{name: "some name"}, host)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_invitation(@invalid_attrs, user_group, host, invitee)
    end

    test "update_invitation/2 with valid data updates the invitation" do
      %{invitation: invitation} = invitation_fixture()

      assert {:ok, %Invitation{} = invitation} =
               Accounts.update_invitation(invitation, @update_attrs)
    end

    test "delete_invitation/1 deletes the invitation" do
      %{invitation: invitation} = invitation_fixture()
      assert {:ok, %Invitation{}} = Accounts.delete_invitation(invitation)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_invitation!(invitation.id) end
    end

    test "change_invitation/1 returns a invitation changeset" do
      %{invitation: invitation} = invitation_fixture()
      assert %Ecto.Changeset{} = Accounts.change_invitation(invitation)
    end
  end
end
