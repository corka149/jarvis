defmodule Jarvis.Inventories.Place do
  @moduledoc """
  Database module for the entity place.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "isles" do
    field :name, :string
    has_many :items, Jarvis.Inventories.Item, foreign_key: :belongs_to

    belongs_to :user_group, Jarvis.Accounts.UserGroup, foreign_key: :owned_by

    timestamps()
  end

  @doc false
  def changeset(place, attrs) do
    place
    |> cast(attrs, [:name, :owned_by])
    |> validate_required([:name, :owned_by])
  end
end
