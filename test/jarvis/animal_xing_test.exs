defmodule Jarvis.AnimalXingTest do
  use Jarvis.DataCase

  alias Jarvis.AnimalXing

  describe "artworks" do
    alias Jarvis.AnimalXing.Artwork

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def artwork_fixture(attrs \\ %{}) do
      {:ok, artwork} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AnimalXing.create_artwork()

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
      assert {:ok, %Artwork{} = artwork} = AnimalXing.create_artwork(@valid_attrs)
      assert artwork.name == "some name"
    end

    test "create_artwork/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AnimalXing.create_artwork(@invalid_attrs)
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
end
