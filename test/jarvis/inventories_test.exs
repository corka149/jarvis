defmodule Jarvis.InventoriesTest do
  use Jarvis.DataCase

  alias Jarvis.InventoriesRepo
  import Jarvis.TestHelper

  describe "items" do
    alias Jarvis.Inventories.Item

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    @valid_attrs_place %{name: "some name"}

    def item_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)
      {:ok, place} = InventoriesRepo.create_place(@valid_attrs_place, user_group)

      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InventoriesRepo.create_item(place)

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      item = %{item | place: nil}

      item_from_db = InventoriesRepo.list_items() |> Enum.map(fn a -> %{a | place: nil} end)

      assert item_from_db == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      item = %{item | place: nil}

      item_from_db = InventoriesRepo.get_item!(item.id)
      item_from_db = %{item_from_db | place: nil}

      assert item_from_db == item
    end

    test "create_item/1 with valid data creates a item" do
      user_group = gen_test_data(:user_group)
      {:ok, place} = InventoriesRepo.create_place(@valid_attrs_place, user_group)

      assert {:ok, %Item{} = item} = InventoriesRepo.create_item(@valid_attrs, place)
      assert item.name == "some name"
    end

    test "create_item/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)
      {:ok, place} = InventoriesRepo.create_place(@valid_attrs_place, user_group)

      assert {:error, %Ecto.Changeset{}} = InventoriesRepo.create_item(@invalid_attrs, place)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = InventoriesRepo.update_item(item, @update_attrs)
      assert item.name == "some updated name"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      item = %{item | place: nil}

      assert {:error, %Ecto.Changeset{}} = InventoriesRepo.update_item(item, @invalid_attrs)

      item_from_db = InventoriesRepo.get_item!(item.id)
      item_from_db = %{item_from_db | place: nil}

      assert item == item_from_db
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = InventoriesRepo.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> InventoriesRepo.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = InventoriesRepo.change_item(item)
    end
  end

  describe "places" do
    alias Jarvis.Inventories.Place

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def place_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)

      {:ok, place} =
        attrs
        |> Enum.into(@valid_attrs)
        |> InventoriesRepo.create_place(user_group)

      place
    end

    test "list_places/0 returns all places" do
      place = place_fixture()
      place = %{place | user_group: nil}

      place_from_db =
        InventoriesRepo.list_places() |> Enum.map(fn i -> %{i | user_group: nil} end)

      assert place_from_db == [place]
    end

    test "get_place!/1 returns the place with given id" do
      place = place_fixture()
      place = Map.delete(place, :user_group)

      place_from_db = InventoriesRepo.get_place!(place.id)
      place_from_db = Map.delete(place_from_db, :user_group)

      assert place_from_db == place
    end

    test "create_place/1 with valid data creates a place" do
      user_group = gen_test_data(:user_group)

      assert {:ok, %Place{} = place} = InventoriesRepo.create_place(@valid_attrs, user_group)
      assert place.name == "some name"
    end

    test "create_place/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)

      assert {:error, %Ecto.Changeset{}} =
               InventoriesRepo.create_place(@invalid_attrs, user_group)
    end

    test "update_place/2 with valid data updates the place" do
      place = place_fixture()
      assert {:ok, %Place{} = place} = InventoriesRepo.update_place(place, @update_attrs)
      assert place.name == "some updated name"
    end

    test "update_place/2 with invalid data returns error changeset" do
      place = place_fixture()
      place = Map.delete(place, :user_group)

      assert {:error, %Ecto.Changeset{}} = InventoriesRepo.update_place(place, @invalid_attrs)

      place_from_db = InventoriesRepo.get_place!(place.id)
      place_from_db = Map.delete(place_from_db, :user_group)

      assert place == place_from_db
    end

    test "delete_place/1 deletes the place" do
      place = place_fixture()
      assert {:ok, %Place{}} = InventoriesRepo.delete_place(place)
      assert_raise Ecto.NoResultsError, fn -> InventoriesRepo.get_place!(place.id) end
    end

    test "change_place/1 returns a place changeset" do
      place = place_fixture()
      assert %Ecto.Changeset{} = InventoriesRepo.change_place(place)
    end
  end
end
