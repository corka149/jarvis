defmodule Jarvis.Inventory.Item do
  @moduledoc """
  Database module for the entity item.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :name, :string
    belongs_to :place, Jarvis.Inventory.Place, foreign_key: :belongs_to

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :belongs_to])
    |> validate_required([:name, :belongs_to])
  end
end
