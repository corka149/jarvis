defmodule Jarvis.ShoppingListsTest do
  use Jarvis.DataCase

  alias Jarvis.AccountsRepo
  alias Jarvis.ShoppingListsRepo

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
      {:ok, user} = AccountsRepo.create_user(@valid_attrs_user)
      {_, group} = AccountsRepo.create_user_group(@valid_attrs_group, user)

      {:ok, shopping_list} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ShoppingListsRepo.create_shopping_list(group)

      shopping_list
    end

    test "list_shoppinglists/0 returns all shoppinglists" do
      shopping_list =
        shopping_list_fixture()
        |> Jarvis.Repo.preload(:usergroup)

      assert ShoppingListsRepo.list_shoppinglists() == [shopping_list]
    end

    test "get_shopping_list!/1 returns the shopping_list with given id" do
      shopping_list =
        shopping_list_fixture()
        |> Jarvis.Repo.preload(:usergroup)

      assert ShoppingListsRepo.get_shopping_list!(shopping_list.id) == shopping_list
    end

    test "create_shopping_list/1 with valid data creates a shopping_list" do
      {:ok, user} = AccountsRepo.create_user(@valid_attrs_user)
      {_, group} = AccountsRepo.create_user_group(@valid_attrs_group, user)

      assert {:ok, %ShoppingList{} = shopping_list} =
               ShoppingListsRepo.create_shopping_list(@valid_attrs, group)

      assert shopping_list.done == true
      assert shopping_list.planned_for == ~D[2010-04-17]
    end

    test "create_shopping_list/1 with invalid data returns error changeset" do
      {:ok, user} = AccountsRepo.create_user(@valid_attrs_user)
      {_, group} = AccountsRepo.create_user_group(@valid_attrs_group, user)

      assert {:error, %Ecto.Changeset{}} =
               ShoppingListsRepo.create_shopping_list(@invalid_attrs, group)
    end

    test "update_shopping_list/2 with valid data updates the shopping_list" do
      shopping_list = shopping_list_fixture()

      assert {:ok, %ShoppingList{} = shopping_list} =
               ShoppingListsRepo.update_shopping_list(shopping_list, @update_attrs)

      assert shopping_list.done == false
      assert shopping_list.planned_for == ~D[2011-05-18]
    end

    test "update_shopping_list/2 with invalid data returns error changeset" do
      shopping_list =
        shopping_list_fixture()
        |> Jarvis.Repo.preload(:usergroup)

      assert {:error, %Ecto.Changeset{}} =
               ShoppingListsRepo.update_shopping_list(shopping_list, @invalid_attrs)

      assert shopping_list == ShoppingListsRepo.get_shopping_list!(shopping_list.id)
    end

    test "delete_shopping_list/1 deletes the shopping_list" do
      shopping_list = shopping_list_fixture()
      assert {:ok, %ShoppingList{}} = ShoppingListsRepo.delete_shopping_list(shopping_list)

      assert_raise Ecto.NoResultsError, fn ->
        ShoppingListsRepo.get_shopping_list!(shopping_list.id)
      end
    end

    test "change_shopping_list/1 returns a shopping_list changeset" do
      shopping_list = shopping_list_fixture()
      assert %Ecto.Changeset{} = ShoppingListsRepo.change_shopping_list(shopping_list)
    end
  end
end
