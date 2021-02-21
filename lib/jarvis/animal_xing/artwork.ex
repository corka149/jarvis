defmodule Jarvis.AnimalXing.Artwork do
  use Ecto.Schema
  import Ecto.Changeset

  schema "artworks" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(artwork, attrs) do
    artwork
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
