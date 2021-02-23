defmodule Jarvis.AnimalXingTest do
  use Jarvis.DataCase

  alias Jarvis.AnimalXing

  import Jarvis.TestHelper

  describe "artworks" do
    alias Jarvis.AnimalXing.Artwork

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    @valid_attrs_isle %{name: "some name"}

    def artwork_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)
      {:ok, isle} = AnimalXing.create_isle(@valid_attrs_isle, user_group)

      {:ok, artwork} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AnimalXing.create_artwork(isle)

      artwork
    end

    test "list_artworks/0 returns all artworks" do
      artwork = artwork_fixture()
      assert AnimalXing.list_artworks() == [artwork]
    end

    test "get_artwork!/1 returns the artwork with given id" do
      artwork = artwork_fixture()
      assert AnimalXing.get_artwork!(artwork.id) == artwork
    end

    test "create_artwork/1 with valid data creates a artwork" do
      user_group = gen_test_data(:user_group)
      {:ok, isle} = AnimalXing.create_isle(@valid_attrs_isle, user_group)

      assert {:ok, %Artwork{} = artwork} = AnimalXing.create_artwork(@valid_attrs, isle)
      assert artwork.name == "some name"
    end

    test "create_artwork/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)
      {:ok, isle} = AnimalXing.create_isle(@valid_attrs_isle, user_group)

      assert {:error, %Ecto.Changeset{}} = AnimalXing.create_artwork(@invalid_attrs, isle)
    end

    test "update_artwork/2 with valid data updates the artwork" do
      artwork = artwork_fixture()
      assert {:ok, %Artwork{} = artwork} = AnimalXing.update_artwork(artwork, @update_attrs)
      assert artwork.name == "some updated name"
    end

    test "update_artwork/2 with invalid data returns error changeset" do
      artwork = artwork_fixture()
      assert {:error, %Ecto.Changeset{}} = AnimalXing.update_artwork(artwork, @invalid_attrs)
      assert artwork == AnimalXing.get_artwork!(artwork.id)
    end

    test "delete_artwork/1 deletes the artwork" do
      artwork = artwork_fixture()
      assert {:ok, %Artwork{}} = AnimalXing.delete_artwork(artwork)
      assert_raise Ecto.NoResultsError, fn -> AnimalXing.get_artwork!(artwork.id) end
    end

    test "change_artwork/1 returns a artwork changeset" do
      artwork = artwork_fixture()
      assert %Ecto.Changeset{} = AnimalXing.change_artwork(artwork)
    end
  end

  describe "isles" do
    alias Jarvis.AnimalXing.Isle

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def isle_fixture(attrs \\ %{}) do
      user_group = gen_test_data(:user_group)

      {:ok, isle} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AnimalXing.create_isle(user_group)

      isle
    end

    test "list_isles/0 returns all isles" do
      isle = isle_fixture()
      assert AnimalXing.list_isles() == [isle]
    end

    test "get_isle!/1 returns the isle with given id" do
      isle = isle_fixture()
      assert AnimalXing.get_isle!(isle.id) == isle
    end

    test "create_isle/1 with valid data creates a isle" do
      user_group = gen_test_data(:user_group)

      assert {:ok, %Isle{} = isle} = AnimalXing.create_isle(@valid_attrs, user_group)
      assert isle.name == "some name"
    end

    test "create_isle/1 with invalid data returns error changeset" do
      user_group = gen_test_data(:user_group)

      assert {:error, %Ecto.Changeset{}} = AnimalXing.create_isle(@invalid_attrs, user_group)
    end

    test "update_isle/2 with valid data updates the isle" do
      isle = isle_fixture()
      assert {:ok, %Isle{} = isle} = AnimalXing.update_isle(isle, @update_attrs)
      assert isle.name == "some updated name"
    end

    test "update_isle/2 with invalid data returns error changeset" do
      isle = isle_fixture()
      assert {:error, %Ecto.Changeset{}} = AnimalXing.update_isle(isle, @invalid_attrs)
      assert isle == AnimalXing.get_isle!(isle.id)
    end

    test "delete_isle/1 deletes the isle" do
      isle = isle_fixture()
      assert {:ok, %Isle{}} = AnimalXing.delete_isle(isle)
      assert_raise Ecto.NoResultsError, fn -> AnimalXing.get_isle!(isle.id) end
    end

    test "change_isle/1 returns a isle changeset" do
      isle = isle_fixture()
      assert %Ecto.Changeset{} = AnimalXing.change_isle(isle)
    end
  end
end
