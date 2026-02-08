defmodule Jarvis.ShoppingTest do
  use Jarvis.DataCase

  alias Jarvis.Shopping

  describe "shopping_lists" do
    alias Jarvis.Shopping.List

    import Jarvis.ShoppingFixtures

    @invalid_attrs %{status: nil, title: nil, purchase_at: nil}

    test "list_shopping_lists/0 returns all shopping_lists" do
      list = list_fixture()
      assert Shopping.list_shopping_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert Shopping.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      valid_attrs = %{status: :open, title: "some title", purchase_at: ~D[2026-02-07]}

      assert {:ok, %List{} = list} = Shopping.create_list(valid_attrs)
      assert list.status == :open
      assert list.title == "some title"
      assert list.purchase_at == ~D[2026-02-07]
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shopping.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      update_attrs = %{status: :done, title: "some updated title", purchase_at: ~D[2026-02-08]}

      assert {:ok, %List{} = list} = Shopping.update_list(list, update_attrs)
      assert list.status == :done
      assert list.title == "some updated title"
      assert list.purchase_at == ~D[2026-02-08]
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = Shopping.update_list(list, @invalid_attrs)
      assert list == Shopping.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = Shopping.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> Shopping.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = Shopping.change_list(list)
    end
  end
end
