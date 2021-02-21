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

      iex> create_artwork(%{field: value})
      {:ok, %Artwork{}}

      iex> create_artwork(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_artwork(attrs \\ %{}) do
    %Artwork{}
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
end
