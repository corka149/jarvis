defmodule Jarvis.InventoryTest do
  use Jarvis.DataCase

  alias Jarvis.Inventory

  import Jarvis.TestHelper

  describe "artworks" do
    alias Jarvis.Inventory.Artwork

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    @valid_attrs_place %{name: "some name"}

    def artwork_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)
      {:ok, place} = Inventory.create_place(@valid_attrs_place, user_group)

      {:ok, artwork} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_artwork(place)

      artwork
    end

    test "list_artworks/0 returns all artworks" do
      artwork = artwork_fixture()
      artwork = %{artwork | place: nil}

      artwork_from_db = Inventory.list_artworks() |> Enum.map(fn a -> %{a | place: nil} end)

      assert artwork_from_db == [artwork]
    end

    test "get_artwork!/1 returns the artwork with given id" do
      artwork = artwork_fixture()
      artwork = %{artwork | place: nil}

      artwork_from_db = Inventory.get_artwork!(artwork.id)
      artwork_from_db = %{artwork_from_db | place: nil}

      assert artwork_from_db == artwork
    end

    test "create_artwork/1 with valid data creates a artwork" do
      user_group = gen_test_data(:user_group)
      {:ok, place} = Inventory.create_place(@valid_attrs_place, user_group)

      assert {:ok, %Artwork{} = artwork} = Inventory.create_artwork(@valid_attrs, place)
      assert artwork.name == "some name"
    end

    test "create_artwork/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)
      {:ok, place} = Inventory.create_place(@valid_attrs_place, user_group)

      assert {:error, %Ecto.Changeset{}} = Inventory.create_artwork(@invalid_attrs, place)
    end

    test "update_artwork/2 with valid data updates the artwork" do
      artwork = artwork_fixture()
      assert {:ok, %Artwork{} = artwork} = Inventory.update_artwork(artwork, @update_attrs)
      assert artwork.name == "some updated name"
    end

    test "update_artwork/2 with invalid data returns error changeset" do
      artwork = artwork_fixture()
      artwork = %{artwork | place: nil}

      assert {:error, %Ecto.Changeset{}} = Inventory.update_artwork(artwork, @invalid_attrs)

      artwork_from_db = Inventory.get_artwork!(artwork.id)
      artwork_from_db = %{artwork_from_db | place: nil}

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

  describe "places" do
    alias Jarvis.Inventory.Place

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def place_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)

      {:ok, place} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Inventory.create_place(user_group)

      place
    end

    test "list_places/0 returns all places" do
      place = place_fixture()
      place = %{place | user_group: nil}

      place_from_db = Inventory.list_places() |> Enum.map(fn i -> %{i | user_group: nil} end)

      assert place_from_db == [place]
    end

    test "get_place!/1 returns the place with given id" do
      place = place_fixture()
      place = Map.delete(place, :user_group)

      place_from_db = Inventory.get_place!(place.id)
      place_from_db = Map.delete(place_from_db, :user_group)

      assert place_from_db == place
    end

    test "create_place/1 with valid data creates a place" do
      user_group = gen_test_data(:user_group)

      assert {:ok, %Place{} = place} = Inventory.create_place(@valid_attrs, user_group)
      assert place.name == "some name"
    end

    test "create_place/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)

      assert {:error, %Ecto.Changeset{}} = Inventory.create_place(@invalid_attrs, user_group)
    end

    test "update_place/2 with valid data updates the place" do
      place = place_fixture()
      assert {:ok, %Place{} = place} = Inventory.update_place(place, @update_attrs)
      assert place.name == "some updated name"
    end

    test "update_place/2 with invalid data returns error changeset" do
      place = place_fixture()
      place = Map.delete(place, :user_group)

      assert {:error, %Ecto.Changeset{}} = Inventory.update_place(place, @invalid_attrs)

      place_from_db = Inventory.get_place!(place.id)
      place_from_db = Map.delete(place_from_db, :user_group)

      assert place == place_from_db
    end

    test "delete_place/1 deletes the place" do
      place = place_fixture()
      assert {:ok, %Place{}} = Inventory.delete_place(place)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_place!(place.id) end
    end

    test "change_place/1 returns a place changeset" do
      place = place_fixture()
      assert %Ecto.Changeset{} = Inventory.change_place(place)
    end
  end
end
