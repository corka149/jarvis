defmodule Jarvis.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.Inventory.Artwork

  @doc """
  Returns the list of artworks.

  ## Examples

      iex> list_artworks()
      [%Artwork{}, ...]

  """
  def list_artworks do
    Repo.all(Artwork) |> Repo.preload(:place)
  end

  @doc """
  Gets a single artwork.

  Raises `Ecto.NoResultsError` if the Artwork does not exist.

  ## Examples

      iex> get_artwork!(123)
      %Artwork{}

      iex> get_artwork!(456)
      ** (Ecto.NoResultsError)

  """
  def get_artwork!(id), do: Repo.get!(Artwork, id) |> Repo.preload(:place)

  @doc """
  Creates a artwork.

  ## Examples

      iex> create_artwork(%{field: value}, place)
      {:ok, %Artwork{}}

      iex> create_artwork(%{field: bad_value}, place)
      {:error, %Ecto.Changeset{}}

  """
  def create_artwork(attrs \\ %{}, place) do
    Ecto.build_assoc(place, :artworks)
    |> Artwork.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a artwork.

  ## Examples

      iex> update_artwork(artwork, %{field: new_value})
      {:ok, %Artwork{}}

      iex> update_artwork(artwork, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_artwork(%Artwork{} = artwork, attrs) do
    artwork
    |> Artwork.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a artwork.

  ## Examples

      iex> delete_artwork(artwork)
      {:ok, %Artwork{}}

      iex> delete_artwork(artwork)
      {:error, %Ecto.Changeset{}}

  """
  def delete_artwork(%Artwork{} = artwork) do
    Repo.delete(artwork)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artwork changes.

  ## Examples

      iex> change_artwork(artwork)
      %Ecto.Changeset{data: %Artwork{}}

  """
  def change_artwork(%Artwork{} = artwork, attrs \\ %{}) do
    Artwork.changeset(artwork, attrs)
  end

  alias Jarvis.Inventory.Place

  @doc """
  Returns the list of places.

  ## Examples

      iex> list_places()
      [%Place{}, ...]

  """
  def list_places do
    Repo.all(Place) |> Repo.preload(:user_group)
  end

  @doc """
  Gets a single place.

  Raises `Ecto.NoResultsError` if the Place does not exist.

  ## Examples

      iex> get_place!(123)
      %Place{}

      iex> get_place!(456)
      ** (Ecto.NoResultsError)

  """
  def get_place!(id), do: Repo.get!(Place, id) |> Repo.preload(:user_group)

  @doc """
  Creates a place.

  ## Examples

      iex> create_place(%{field: value}, user_group)
      {:ok, %Place{}}

      iex> create_place(%{field: bad_value}, user_group)
      {:error, %Ecto.Changeset{}}

  """
  def create_place(attrs \\ %{}, user_group) do
    Ecto.build_assoc(user_group, :places)
    |> Place.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a place.

  ## Examples

      iex> update_place(place, %{field: new_value})
      {:ok, %Place{}}

      iex> update_place(place, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_place(%Place{} = place, attrs) do
    place
    |> Place.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a place.

  ## Examples

      iex> delete_place(place)
      {:ok, %Place{}}

      iex> delete_place(place)
      {:error, %Ecto.Changeset{}}

  """
  def delete_place(%Place{} = place) do
    Repo.delete(place)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking place changes.

  ## Examples

      iex> change_place(place)
      %Ecto.Changeset{data: %Place{}}

  """
  def change_place(%Place{} = place, attrs \\ %{}) do
    Place.changeset(place, attrs)
  end
end
