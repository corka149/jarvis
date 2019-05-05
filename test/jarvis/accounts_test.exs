defmodule Jarvis.AccountsTest do
  use Jarvis.DataCase

  alias Jarvis.Accounts

  describe "users" do
    alias Jarvis.Accounts.User

    @valid_attrs %{email: "some email", name: "some name", provider: "some provider", token: "some token"}
    @update_attrs %{email: "some updated email", name: "some updated name", provider: "some updated provider", token: "some updated token"}
    @invalid_attrs %{email: nil, name: nil, provider: nil, token: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.name == "some name"
      assert user.provider == "some provider"
      assert user.token == "some token"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.name == "some updated name"
      assert user.provider == "some updated provider"
      assert user.token == "some updated token"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
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

    def user_group_fixture(attrs \\ %{}) do
      {:ok, user_group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user_group()

      user_group
    end

    test "list_usergroups/0 returns all usergroups" do
      user_group = user_group_fixture()
      assert Accounts.list_usergroups() == [user_group]
    end

    test "get_user_group!/1 returns the user_group with given id" do
      user_group = user_group_fixture()
      assert Accounts.get_user_group!(user_group.id) == user_group
    end

    test "create_user_group/1 with valid data creates a user_group" do
      assert {:ok, %UserGroup{} = user_group} = Accounts.create_user_group(@valid_attrs)
      assert user_group.name == "some name"
    end

    test "create_user_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_group(@invalid_attrs)
    end

    test "update_user_group/2 with valid data updates the user_group" do
      user_group = user_group_fixture()
      assert {:ok, %UserGroup{} = user_group} = Accounts.update_user_group(user_group, @update_attrs)
      assert user_group.name == "some updated name"
    end

    test "update_user_group/2 with invalid data returns error changeset" do
      user_group = user_group_fixture()
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
end
