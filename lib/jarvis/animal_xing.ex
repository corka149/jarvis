defmodule Jarvis.AnimalXing do
  @moduledoc """
  The AnimalXing context.
  """

  import Ecto.Query, warn: false
  alias Jarvis.Repo

  alias Jarvis.AnimalXing.Artwork

  @doc """
  Returns the list of artworks.

  ## Examples

      iex> list_artworks()
      [%Artwork{}, ...]

  """
  def list_artworks do
    Repo.all(Artwork)
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
  def get_artwork!(id), do: Repo.get!(Artwork, id)

  @doc """
  Creates a artwork.

  ## Examples

      iex> create_artwork(%{field: value}, isle)
      {:ok, %Artwork{}}

      iex> create_artwork(%{field: bad_value}, isle)
      {:error, %Ecto.Changeset{}}

  """
  def create_artwork(attrs \\ %{}, isle) do
    Ecto.build_assoc(isle, :artworks)
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

  alias Jarvis.AnimalXing.Isle

  @doc """
  Returns the list of isles.

  ## Examples

      iex> list_isles()
      [%Isle{}, ...]

  """
  def list_isles do
    Repo.all(Isle)
  end

  @doc """
  Gets a single isle.

  Raises `Ecto.NoResultsError` if the Isle does not exist.

  ## Examples

      iex> get_isle!(123)
      %Isle{}

      iex> get_isle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_isle!(id), do: Repo.get!(Isle, id)

  @doc """
  Creates a isle.

  ## Examples

      iex> create_isle(%{field: value}, user_group)
      {:ok, %Isle{}}

      iex> create_isle(%{field: bad_value}, user_group)
      {:error, %Ecto.Changeset{}}

  """
  def create_isle(attrs \\ %{}, user_group) do
    Ecto.build_assoc(user_group, :isles)
    |> Isle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a isle.

  ## Examples

      iex> update_isle(isle, %{field: new_value})
      {:ok, %Isle{}}

      iex> update_isle(isle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_isle(%Isle{} = isle, attrs) do
    isle
    |> Isle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a isle.

  ## Examples

      iex> delete_isle(isle)
      {:ok, %Isle{}}

      iex> delete_isle(isle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_isle(%Isle{} = isle) do
    Repo.delete(isle)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking isle changes.

  ## Examples

      iex> change_isle(isle)
      %Ecto.Changeset{data: %Isle{}}

  """
  def change_isle(%Isle{} = isle, attrs \\ %{}) do
    Isle.changeset(isle, attrs)
  end
end
