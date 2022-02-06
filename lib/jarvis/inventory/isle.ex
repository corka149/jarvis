defmodule Jarvis.Inventory.Isle do
  @moduledoc """
  Database module for the entity isle.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "isles" do
    field :name, :string
    has_many :artworks, Jarvis.Inventory.Artwork, foreign_key: :belongs_to

    belongs_to :user_group, Jarvis.Accounts.UserGroup, foreign_key: :owned_by

    timestamps()
  end

  @doc false
  def changeset(isle, attrs) do
    isle
    |> cast(attrs, [:name, :owned_by])
    |> validate_required([:name, :owned_by])
  end
end
