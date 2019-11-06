defmodule Jarvis.ShoppingListsTest do
  use Jarvis.DataCase

  alias Jarvis.ShoppingLists

  describe "shoppinglists" do
    alias Jarvis.ShoppingLists.ShoppingList

    @valid_attrs %{done: true, planned_for: ~D[2010-04-17]}
    @update_attrs %{done: false, planned_for: ~D[2011-05-18]}
    @invalid_attrs %{done: nil, planned_for: nil}

    @valid_attrs_group %{name: "some name"}
    @valid_attrs_user %{
      email: "someemail@test.xyz",
      name: "some name",
      provider: "some provider",
      token: "some token"
    }

    def shopping_list_fixture(attrs \\ %{}) do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
      {_, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)

      {:ok, shopping_list} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ShoppingLists.create_shopping_list(group)

      shopping_list
    end

    test "list_shoppinglists/0 returns all shoppinglists" do
      shopping_list =
        shopping_list_fixture()
        |> Jarvis.Repo.preload(:usergroup)

      assert ShoppingLists.list_shoppinglists() == [shopping_list]
    end

    test "get_shopping_list!/1 returns the shopping_list with given id" do
      shopping_list =
        shopping_list_fixture()
        |> Jarvis.Repo.preload(:usergroup)

      assert ShoppingLists.get_shopping_list!(shopping_list.id) == shopping_list
    end

    test "create_shopping_list/1 with valid data creates a shopping_list" do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
      {_, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)

      assert {:ok, %ShoppingList{} = shopping_list} =
               ShoppingLists.create_shopping_list(@valid_attrs, group)

      assert shopping_list.done == true
      assert shopping_list.planned_for == ~D[2010-04-17]
    end

    test "create_shopping_list/1 with invalid data returns error changeset" do
      {:ok, user} = Jarvis.Accounts.create_user(@valid_attrs_user)
      {_, group} = Jarvis.Accounts.create_user_group(@valid_attrs_group, user)

      assert {:error, %Ecto.Changeset{}} =
               ShoppingLists.create_shopping_list(@invalid_attrs, group)
    end

    test "update_shopping_list/2 with valid data updates the shopping_list" do
      shopping_list = shopping_list_fixture()

      assert {:ok, %ShoppingList{} = shopping_list} =
               ShoppingLists.update_shopping_list(shopping_list, @update_attrs)

      assert shopping_list.done == false
      assert shopping_list.planned_for == ~D[2011-05-18]
    end

    test "update_shopping_list/2 with invalid data returns error changeset" do
      shopping_list =
        shopping_list_fixture()
        |> Jarvis.Repo.preload(:usergroup)

      assert {:error, %Ecto.Changeset{}} =
               ShoppingLists.update_shopping_list(shopping_list, @invalid_attrs)

      assert shopping_list == ShoppingLists.get_shopping_list!(shopping_list.id)
    end

    test "delete_shopping_list/1 deletes the shopping_list" do
      shopping_list = shopping_list_fixture()
      assert {:ok, %ShoppingList{}} = ShoppingLists.delete_shopping_list(shopping_list)

      assert_raise Ecto.NoResultsError, fn ->
        ShoppingLists.get_shopping_list!(shopping_list.id)
      end
    end

    test "change_shopping_list/1 returns a shopping_list changeset" do
      shopping_list = shopping_list_fixture()
      assert %Ecto.Changeset{} = ShoppingLists.change_shopping_list(shopping_list)
    end
  end
end
