defmodule Jarvis.Inventory.Artwork do
  @moduledoc """
  Database module for the entity artwork.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "artworks" do
    field :name, :string
    belongs_to :place, Jarvis.Inventory.Place, foreign_key: :belongs_to

    timestamps()
  end

  @doc false
  def changeset(artwork, attrs) do
    artwork
    |> cast(attrs, [:name, :belongs_to])
    |> validate_required([:name, :belongs_to])
  end
end
