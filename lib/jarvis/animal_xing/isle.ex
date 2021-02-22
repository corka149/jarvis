defmodule Jarvis.AnimalXing.Isle do
  @moduledoc """
  Database module for the entity isle.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "isles" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(isle, attrs) do
    isle
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
