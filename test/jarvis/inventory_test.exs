defmodule Jarvis.InventoryTest do
  use Jarvis.DataCase

  alias Jarvis.Inventory

  import Jarvis.TestHelper

  describe "artworks" do
    alias Jarvis.Inventory.Artwork

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    @valid_attrs_isle %{name: "some name"}

    def artwork_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)
      {:ok, isle} = Inventory.create_isle(@valid_attrs_isle, user_group)

      {:ok, artwork} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_artwork(isle)

      artwork
    end

    test "list_artworks/0 returns all artworks" do
      artwork = artwork_fixture()
      artwork = %{artwork | isle: nil}

      artwork_from_db = Inventory.list_artworks() |> Enum.map(fn a -> %{a | isle: nil} end)

      assert artwork_from_db == [artwork]
    end

    test "get_artwork!/1 returns the artwork with given id" do
      artwork = artwork_fixture()
      artwork = %{artwork | isle: nil}

      artwork_from_db = Inventory.get_artwork!(artwork.id)
      artwork_from_db = %{artwork_from_db | isle: nil}

      assert artwork_from_db == artwork
    end

    test "create_artwork/1 with valid data creates a artwork" do
      user_group = gen_test_data(:user_group)
      {:ok, isle} = Inventory.create_isle(@valid_attrs_isle, user_group)

      assert {:ok, %Artwork{} = artwork} = Inventory.create_artwork(@valid_attrs, isle)
      assert artwork.name == "some name"
    end

    test "create_artwork/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)
      {:ok, isle} = Inventory.create_isle(@valid_attrs_isle, user_group)

      assert {:error, %Ecto.Changeset{}} = Inventory.create_artwork(@invalid_attrs, isle)
    end

    test "update_artwork/2 with valid data updates the artwork" do
      artwork = artwork_fixture()
      assert {:ok, %Artwork{} = artwork} = Inventory.update_artwork(artwork, @update_attrs)
      assert artwork.name == "some updated name"
    end

    test "update_artwork/2 with invalid data returns error changeset" do
      artwork = artwork_fixture()
      artwork = %{artwork | isle: nil}

      assert {:error, %Ecto.Changeset{}} = Inventory.update_artwork(artwork, @invalid_attrs)

      artwork_from_db = Inventory.get_artwork!(artwork.id)
      artwork_from_db = %{artwork_from_db | isle: nil}

      assert artwork == artwork_from_db
    end

    test "delete_artwork/1 deletes the artwork" do
      artwork = artwork_fixture()
      assert {:ok, %Artwork{}} = Inventory.delete_artwork(artwork)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_artwork!(artwork.id) end
    end

    test "change_artwork/1 returns a artwork changeset" do
      artwork = artwork_fixture()
      assert %Ecto.Changeset{} = Inventory.change_artwork(artwork)
    end
  end

  describe "isles" do
    alias Jarvis.Inventory.Isle

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def isle_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)

      {:ok, isle} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_isle(user_group)

      isle
    end

    test "list_isles/0 returns all isles" do
      isle = isle_fixture()
      isle = %{isle | user_group: nil}

      isle_from_db = Inventory.list_isles() |> Enum.map(fn i -> %{i | user_group: nil} end)

      assert isle_from_db == [isle]
    end

    test "get_isle!/1 returns the isle with given id" do
      isle = isle_fixture()
      isle = Map.delete(isle, :user_group)

      isle_from_db = Inventory.get_isle!(isle.id)
      isle_from_db = Map.delete(isle_from_db, :user_group)

      assert isle_from_db == isle
    end

    test "create_isle/1 with valid data creates a isle" do
      user_group = gen_test_data(:user_group)

      assert {:ok, %Isle{} = isle} = Inventory.create_isle(@valid_attrs, user_group)
      assert isle.name == "some name"
    end

    test "create_isle/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)

      assert {:error, %Ecto.Changeset{}} = Inventory.create_isle(@invalid_attrs, user_group)
    end

    test "update_isle/2 with valid data updates the isle" do
      isle = isle_fixture()
      assert {:ok, %Isle{} = isle} = Inventory.update_isle(isle, @update_attrs)
      assert isle.name == "some updated name"
    end

    test "update_isle/2 with invalid data returns error changeset" do
      isle = isle_fixture()
      isle = Map.delete(isle, :user_group)

      assert {:error, %Ecto.Changeset{}} = Inventory.update_isle(isle, @invalid_attrs)

      isle_from_db = Inventory.get_isle!(isle.id)
      isle_from_db = Map.delete(isle_from_db, :user_group)

      assert isle == isle_from_db
    end

    test "delete_isle/1 deletes the isle" do
      isle = isle_fixture()
      assert {:ok, %Isle{}} = Inventory.delete_isle(isle)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_isle!(isle.id) end
    end

    test "change_isle/1 returns a isle changeset" do
      isle = isle_fixture()
      assert %Ecto.Changeset{} = Inventory.change_isle(isle)
    end
  end
end
